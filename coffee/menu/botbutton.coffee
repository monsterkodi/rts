###
0000000     0000000   000000000        0000000    000   000  000000000  000000000   0000000   000   000
000   000  000   000     000           000   000  000   000     000        000     000   000  0000  000
0000000    000   000     000           0000000    000   000     000        000     000   000  000 0 000
000   000  000   000     000           000   000  000   000     000        000     000   000  000  0000
0000000     0000000      000           0000000     0000000      000        000      0000000   000   000
###

CanvasButton = require './canvasbutton'
BuyButton    = require './buybutton'
BertaMenu    = require './bertamenu'
BaseMenu     = require './basemenu'
SubMenu      = require './submenu'
TradeMenu    = require './trademenu'
BuildMenu    = require './buildmenu'
BrainMenu    = require './brainmenu'

class BotButton extends CanvasButton

    constructor: (@bot, div) ->

        super div
        
        @world = rts.world
        
        @name = "BotButton #{Bot.string @bot}"
        
        @canvas.id = @bot
        
        construct = @world.construct
        @mesh = new THREE.Mesh construct.botGeoms[construct.geomForBotType @bot], @botMat()
        @mesh.receiveShadow = true
        @mesh.castShadow = true
        @mesh.rotateZ deg2rad 45
        @scene.add @mesh

        switch @bot
            when Bot.mine
                @camera.position.copy vec(0,-1,0.6).normal().mul 1.1
                @camera.lookAt vec 0,0,0          
                post.on 'scienceFinished', @render
            when Bot.trade
                @camera.position.copy vec(0,-1,0.6).normal().mul 1.3
                @camera.lookAt vec 0,0,-0.05
            when Bot.brain
                @camera.position.copy vec(0,-1,0.9).normal().mul 1.3
                @camera.lookAt vec 0,0,-0.05               
                post.on 'scienceUpdated',  @render
                post.on 'scienceQueued',   @render
                post.on 'scienceDequeued', @render
            when Bot.berta
                @camera.position.copy vec(0,-1,0.6).normal().mul 1.3
                @camera.lookAt vec 0,0,0
                post.on 'scienceFinished', @render
            when Bot.build
                @camera.position.copy vec(0,-1,0.6).normal().mul 1.3
                @camera.lookAt vec 0,0,0
            when Bot.base
                @camera.position.copy vec(0,-1,0.6).normal().mul 1.3
                @camera.lookAt vec 0,0,0

        if @bot in Bot.switchable
            post.on 'botState', (type,state,player) => @render() if player == 0

        if @bot in [Bot.brain, Bot.trade]
            post.on 'botDisconnected', @render
            post.on 'botConnected',    @render
            
        @camera.updateProjectionMatrix()                
        @render()
        
    initScene: ->
        
        @scene.background = Color.menu.background
        
        @light = new THREE.DirectionalLight 0xffffff
        @light.position.set -2,-2,2
        @scene.add @light
        
        @scene.add new THREE.AmbientLight 0xffffff
                
        @camera.near = 0.01
        @camera.far = 10
        @camera.fov = 30
        
    # 00000000   0000000    0000000  000   000   0000000  000   000  00000000  000   000  000000000  
    # 000       000   000  000       000   000  000       0000  000  000        000 000      000     
    # 000000    000   000  000       000   000  0000000   000 0 000  0000000     00000       000     
    # 000       000   000  000       000   000       000  000  0000  000        000 000      000     
    # 000        0000000    0000000   0000000   0000000   000   000  00000000  000   000     000     
    
    focusNextBot: ->
        
        bots = @world.botsOfType @bot
        index = (bots.indexOf(@focusBot)+1) % bots.length
        @focusBot = bots[index]
        if @focusBot
            @world.highlightBot @focusBot
            rts.camera.focusOnPos @focusBot.pos
        
    click: -> rts.handle.botButtonClick @
    
    #  0000000  000   000   0000000   000   000  
    # 000       000   000  000   000  000 0 000  
    # 0000000   000000000  000   000  000000000  
    #      000  000   000  000   000  000   000  
    # 0000000   000   000   0000000   00     00  
    
    show: (clss) ->
        
        BotButton.currentlyShown?.del()
        BotButton.currentlyShown = new clss @ 
    
    # 000   000  000   0000000   000   000  000      000   0000000   000   000  000000000  
    # 000   000  000  000        000   000  000      000  000        000   000     000     
    # 000000000  000  000  0000  000000000  000      000  000  0000  000000000     000     
    # 000   000  000  000   000  000   000  000      000  000   000  000   000     000     
    # 000   000  000   0000000   000   000  0000000  000   0000000   000   000     000     
    
    highlight: ->
        
        SubMenu.close()
        
        if @bot in [Bot.mine, Bot.berta] or not @world.botOfType @bot
            @show BuyButton
        else 
            switch @bot
                when Bot.base  then @show BaseMenu  
                when Bot.trade then @show TradeMenu
                when Bot.build then @show BuildMenu
                when Bot.brain then @show BrainMenu
            
        @camera.fov = 28
        @camera.updateProjectionMatrix()
        @mesh.material = @botMat true
        @render()
        
    unhighlight: ->
        
        @camera.fov = 30
        @camera.updateProjectionMatrix()
        @mesh.material = @botMat false
        @render()
        
    update: ->
        
        @mesh.material = @botMat false
        @render()
        
    botMat: (highlight=false) ->
        
        if empty @world.botsOfType @bot
            if highlight then Materials.menu.inactiveHigh else Materials.menu.inactive
        else
            if highlight then Materials.menu.activeHigh else Materials.menu.active
            
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    render: =>
        
        if @bot in Bot.switchable
            
            if bot = @world.botOfType @bot
            
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
            
            trade = rts.world.botOfType @bot
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
                
        if @bot in Bot.limited
            
            @meshes.limit?.parent.remove @meshes.limit
            delete @meshes.limit
            if @world.botsOfType(@bot).length >= science()[Bot.string @bot].limit
                @scene.add @meshes.limit = new THREE.Mesh Geometry.botLimited(@world.botOfType @bot), Materials.menu.inactive
                    
        super()
        
        # 00000000   00000000    0000000    0000000   00000000   00000000   0000000   0000000  
        # 000   000  000   000  000   000  000        000   000  000       000       000       
        # 00000000   0000000    000   000  000  0000  0000000    0000000   0000000   0000000   
        # 000        000   000  000   000  000   000  000   000  000            000       000  
        # 000        000   000   0000000    0000000   000   000  00000000  0000000   0000000   

        ctx = @canvas.getContext '2d'
        
        if @bot == Bot.brain

            ctx.fillStyle = Color.menu.progress.getStyle()
            
            if not rts.world.botOfType(@bot)?.path
                ctx.fillStyle = Color.menu.disconnected.getStyle()

            if progress = Science.currentProgress()
                ctx.fillRect 100-progress, 199, 2*progress+2, 1
                
            for i in [0...Science.queue[0].length]
                ctx.fillRect 100 + i*10 - ((Science.queue[0].length-1)*10/2), 192, 3, 3
                        
module.exports = BotButton
