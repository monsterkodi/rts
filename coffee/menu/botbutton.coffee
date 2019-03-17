###
0000000     0000000   000000000        0000000    000   000  000000000  000000000   0000000   000   000
000   000  000   000     000           000   000  000   000     000        000     000   000  0000  000
0000000    000   000     000           0000000    000   000     000        000     000   000  000 0 000
000   000  000   000     000           000   000  000   000     000        000     000   000  000  0000
0000000     0000000      000           0000000     0000000      000        000      0000000   000   000
###

CanvasButton = require './canvasbutton'
BotMenu      = require './botmenu'
BaseMenu     = require './basemenu'
TradeMenu    = require './trademenu'
BuildMenu    = require './buildmenu'
BrainMenu    = require './brainmenu'

class BotButton extends CanvasButton

    constructor: (@bot, div) ->

        @highFov = 28
        @normFov = 30
        @lightPos = vec -2,-2,2
                
        super div            
                
        @name = "BotButton #{Bot.string @bot}"
        
        @canvas.id = @bot
        
        construct = world.construct
        @mesh = new THREE.Mesh construct.botGeoms[construct.geomForBotType @bot], @botMat()
        @mesh.receiveShadow = true
        @mesh.castShadow = true
        @mesh.rotateZ deg2rad 45
        @scene.add @mesh

        switch @bot
            when Bot.mine
                @camera.position.copy vec(0,-1,0.6).normal().mul 1.1
                @camera.lookAt vec 0,0,0          
                post.on 'scienceFinished', @update
            when Bot.trade
                @camera.position.copy vec(0,-1,0.6).normal().mul 1.3
                @camera.lookAt vec 0,0,-0.05
            when Bot.brain
                @camera.position.copy vec(0,-1,0.9).normal().mul 1.3
                @camera.lookAt vec 0,0,-0.05               
                post.on 'scienceUpdated',  @update
                post.on 'scienceQueued',   @update
                post.on 'scienceDequeued', @update
            when Bot.berta
                @camera.position.copy vec(0,-1,0.6).normal().mul 1.3
                @camera.lookAt vec 0,0,0
                post.on 'scienceFinished', @update
            when Bot.build
                @camera.position.copy vec(0,-1,0.6).normal().mul 1.3
                @camera.lookAt vec 0,0,0
            when Bot.base
                @camera.position.copy vec(0,-1,0.6).normal().mul 1.3
                @camera.lookAt vec 0,0,0

        if @bot in Bot.switchable
            post.on 'botState', (type,state,player) => @update() if player == 0

        if @bot in [Bot.brain, Bot.trade]
            post.on 'botDisconnected', @update
            post.on 'botConnected',    @update
                                    
    # 00000000   0000000    0000000  000   000   0000000  000   000  00000000  000   000  000000000  
    # 000       000   000  000       000   000  000       0000  000  000        000 000      000     
    # 000000    000   000  000       000   000  0000000   000 0 000  0000000     00000       000     
    # 000       000   000  000       000   000       000  000  0000  000        000 000      000     
    # 000        0000000    0000000   0000000   0000000   000   000  00000000  000   000     000     
    
    focusNextBot: ->
        
        bots = world.botsOfType @bot
        index = (bots.indexOf(@focusBot)+1) % bots.length
        @focusBot = bots[index]
        if @focusBot
            world.highlightBot @focusBot
            rts.camera.focusOnPos @focusBot.pos
        
    click: -> 
        
        handle.botButtonClick @
        @update()
    
    middleClick: -> @focusNextBot()
    rightClick: -> 
    
    #  0000000  000   000   0000000   000   000  
    # 000       000   000  000   000  000 0 000  
    # 0000000   000000000  000   000  000000000  
    #      000  000   000  000   000  000   000  
    # 0000000   000   000   0000000   00     00  
    
    show: (clss) ->
        
        if rts.menu.buttons.bot?.botButton != @
            rts.menu.buttons.bot?.del()
            rts.menu.buttons.bot = new clss @
    
    # 000   000  000   0000000   000   000  000      000   0000000   000   000  000000000  
    # 000   000  000  000        000   000  000      000  000        000   000     000     
    # 000000000  000  000  0000  000000000  000      000  000  0000  000000000     000     
    # 000   000  000  000   000  000   000  000      000  000   000  000   000     000     
    # 000   000  000   0000000   000   000  0000000  000   0000000   000   000     000     
    
    highlight: ->
        
        playSound 'menu', 'highlight', @bot
                
        switch @bot
            when Bot.base  then @show BaseMenu  
            when Bot.trade then @show TradeMenu
            when Bot.build then @show BuildMenu
            when Bot.brain then @show BrainMenu
            when Bot.mine  then @show BotMenu
            when Bot.berta then @show BotMenu
  
        super
                
    botMat: () ->
        
        if empty world.botsOfType @bot
            if @highlighted then Materials.menu.inactiveHigh else Materials.menu.inactive
        else
            if @highlighted then Materials.menu.activeHigh else Materials.menu.active
            
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    render: =>
        
        return if world.isMeta
        
        if @bot in Bot.switchable
            
            if bot = world.botOfType @bot
            
                @meshes.state?.parent.remove @meshes.state
                delete @meshes.state
                
                if bot.state == 'off'
                    @scene.add @meshes.state = new THREE.Mesh Geometry.botPaused(), Materials.state.paused
                    
        # 000000000  00000000    0000000   0000000    00000000  
        #    000     000   000  000   000  000   000  000       
        #    000     0000000    000000000  000   000  0000000   
        #    000     000   000  000   000  000   000  000       
        #    000     000   000  000   000  0000000    00000000  
        
        if @bot == Bot.trade

            @meshes.sell?.parent.remove @meshes.sell
            delete @meshes.sell

            @meshes.buy?.parent.remove @meshes.buy
            delete @meshes.buy
            
            trade = world.botOfType @bot
            if trade?.path

                s = 0.07
                geom = new THREE.Geometry
                for i in [0...science().trade.sell]
                    x = 0.1*i - 0.1*(science().trade.sell-1)/2
                    geom.merge new THREE.Geometry().fromBufferGeometry Geometry.cornerBox s, x, -0.25, 0.05
                @scene.add @meshes.sell = new THREE.Mesh geom, Materials.stone[trade.sell]
                
                s = 0.1
                geom = Geometry.cornerBox s, 0, 0, 0.2
                geom.rotateZ deg2rad 45
                @scene.add @meshes.buy  = new THREE.Mesh geom, Materials.stone[trade.buy]
                
        # 000      000  00     00  000  000000000  00000000  0000000    
        # 000      000  000   000  000     000     000       000   000  
        # 000      000  000000000  000     000     0000000   000   000  
        # 000      000  000 0 000  000     000     000       000   000  
        # 0000000  000  000   000  000     000     00000000  0000000    
        
        if @bot in Bot.limited
            
            @meshes.limit?.parent.remove @meshes.limit
            delete @meshes.limit
            if world.botsOfType(@bot).length >= science()[Bot.string @bot].limit
                mat = Materials.state.paused
                if world.botsOfType(@bot).length >= Science.maxValue Bot.string(@bot) + '.limit'
                    mat = Materials.menu.inactive
                @scene.add @meshes.limit = new THREE.Mesh Geometry.botLimited(world.botOfType @bot), mat

        @mesh.material = @botMat()
        
        super
        
        # 00000000   00000000    0000000    0000000   00000000   00000000   0000000   0000000  
        # 000   000  000   000  000   000  000        000   000  000       000       000       
        # 00000000   0000000    000   000  000  0000  0000000    0000000   0000000   0000000   
        # 000        000   000  000   000  000   000  000   000  000            000       000  
        # 000        000   000   0000000    0000000   000   000  00000000  0000000   0000000   

        ctx = @canvas.getContext '2d'
        
        if @bot == Bot.brain

            ctx.fillStyle = Color.menu.progress.getStyle()
            
            if not world.botOfType(@bot)?.path
                ctx.fillStyle = Color.menu.disconnected.getStyle()

            if progress = Science.currentProgress()
                ctx.fillRect @size.x/2-progress*@size.x/200, @size.y-1, 2*progress*@size.x/200+2, 1
                
            for i in [0...Science.queue[0].length]
                ctx.fillRect @size.x/2 + i*10 - ((Science.queue[0].length-1)*10/2), @size.y-8, 3, 3
                
        # 000   000  00000000   0000000   000      000000000  000   000  
        # 000   000  000       000   000  000         000     000   000  
        # 000000000  0000000   000000000  000         000     000000000  
        # 000   000  000       000   000  000         000     000   000  
        # 000   000  00000000  000   000  0000000     000     000   000  
        
        ctx.fillStyle = Color.menu.health.getStyle()
        
        health = (bot, x) =>
            if bot.hitPoints < config[Bot.string @bot].health
                h = @size.y * bot.hitPoints / config[Bot.string @bot].health
                ctx.fillRect x, @size.y-h, 1, h
                true
        
        if @bot not in Bot.limited
            if bot = world.botOfType @bot
                health bot, 0
        else
            bots = world.botsOfType @bot
            index = 0
            for bot in bots
                if health bot, index
                    index++
                        
module.exports = BotButton
