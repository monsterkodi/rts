###
000   000   0000000   000   000  0000000    000      00000000
000   000  000   000  0000  000  000   000  000      000     
000000000  000000000  000 0 000  000   000  000      0000000 
000   000  000   000  000  0000  000   000  000      000     
000   000  000   000  000   000  0000000    0000000  00000000
###

{ post, empty, log, str, _ } = require 'kxk'

{ Face, Bot, Stone } = require './constants'

Science = require './science'
Vector = require './lib/vector'

class Handle

    constructor: (@world) ->
        
    botButtonClick: (button) ->
        
        if empty @world.botsOfType button.bot
            @buyBot button.bot
        else
            button.focusNextBot()
        
    botClicked: (bot) -> 
    
        hit = rts.castRay()
        
        switch hit?.bot?.type 
            when Bot.build then @buildBotHit bot, hit

    # 0000000    00000000  000       0000000   000   000  
    # 000   000  000       000      000   000   000 000   
    # 000   000  0000000   000      000000000    00000    
    # 000   000  000       000      000   000     000     
    # 0000000    00000000  0000000  000   000     000     
    
    delay: (delta, bot, speed, delay, func) ->

        # log "delay #{Bot.string(bot.type)} #{speed} #{delay} delay:#{bot[delay]}"#, state.science[Bot.string bot.type]
        bot[delay] -= delta
        if bot[delay] <= 0
            if func bot
                if speed == 'mine'
                    s = Science.mineSpeed bot.type
                else
                    s = state.science[Bot.string bot.type][speed]
                bot[delay] += 1/s
            else
                bot[delay] = 0
            
    # 000000000  000   0000000  000   000  
    #    000     000  000       000  000   
    #    000     000  000       0000000    
    #    000     000  000       000  000   
    #    000     000   0000000  000   000  
    
    tickBot: (delta, bot) ->
        
        @delay delta, bot, 'mine', 'mine', @sendPacket
                            
        switch bot.type 
            when Bot.base  then @tickBase  delta, bot
            when Bot.brain then @tickBrain delta, bot
            when Bot.trade then @tickTrade delta, bot
                
    # 0000000     0000000    0000000  00000000  
    # 000   000  000   000  000       000       
    # 0000000    000000000  0000000   0000000   
    # 000   000  000   000       000  000       
    # 0000000    000   000  0000000   00000000  
    
    tickBase: (delta, bot) ->
        
        @delay delta, bot, 'speed', 'prod', =>
            gained = [0,0,0,0]
            storage = @world.storage
            for stone in Stone.resources
                amount = state.science.base.prod[stone]
                for i in [0...amount]
                    if storage.canTake stone
                        storage.add stone
                        gained[stone] += 1
            @world.spent.gainAtPosFace gained, bot.pos, bot.face
            true
    
    # 0000000    00000000    0000000   000  000   000  
    # 000   000  000   000  000   000  000  0000  000  
    # 0000000    0000000    000000000  000  000 0 000  
    # 000   000  000   000  000   000  000  000  0000  
    # 0000000    000   000  000   000  000  000   000  
    
    tickBrain: (delta, bot) ->
        
        return if state.brain.state != 'on'
        return if not bot.path
        
        @delay delta, bot, 'speed', 'think', =>
            
            if cost = Science.currentCost()
                # log 'tickBrain', cost
                storage = @world.storage
                if storage.canAfford cost
                    Science.deduct cost
                    storage.deduct cost
                    @world.spent.costAtBot cost, bot
                    true
            
    # 000000000  00000000    0000000   0000000    00000000  
    #    000     000   000  000   000  000   000  000       
    #    000     0000000    000000000  000   000  0000000   
    #    000     000   000  000   000  000   000  000       
    #    000     000   000  000   000  0000000    00000000  
    
    tickTrade: (delta, bot) ->
        
        return if state.trade.state != 'on'
        return if not bot.path
        
        @delay delta, bot, 'speed', 'trade', =>
            
            storage    = @world.storage
            sellStone  = state.trade.sell
            sellAmount = state.science.trade.sell
            # log "sell #{sellAmount} #{Stone.string sellStone}"
            if storage.has sellStone, sellAmount
                buyStone = state.trade.buy
                # log "buy #{Stone.string buyStone}"
                if storage.canTake buyStone
                    # log "trade #{sellAmount} #{Stone.string sellStone} for 1 #{Stone.string buyStone}"
                    if @world.tubes.insertPacket bot, buyStone
                        @world.storage.willSend buyStone
                        storage.add sellStone, -sellAmount
                        cost = [0,0,0,0]
                        cost[sellStone] = sellAmount
                        @world.spent.costAtBot cost, bot
                        true
        
    # 0000000    000   000  000   000  
    # 000   000  000   000   000 000   
    # 0000000    000   000    00000    
    # 000   000  000   000     000     
    # 0000000     0000000      000     

    buyButtonClick: (button) -> @buyBot button.bot    
    
    buyBot: (type) ->
                
        cost = state.cost[Bot.string type]
        if not @world.storage.canAfford cost
            log 'WARNING handle.buyBot -- not enough stones for bot!'
            return
        
        if type == Bot.mine
            if @world.botsOfType(type).length >= state.science.mine.limit
                log 'WARNING handle.buyBot -- mine limit reached!'
                return
            
        [p, face] = @world.emptyPosFaceNearBot @world.base
        if not p?
            log 'WARNING handle.buyBot -- no space for new bot!'
            return
        # log "handle.buyBot #{Bot.string type}"

        @world.storage.deduct cost, 'buy'
        bot = @world.addBot p.x,p.y,p.z, type, face
        @world.spent.costAtBot cost, bot
        @world.construct.botAtPos bot, p
        rts.camera.focusOnPos p
        @world.highlightBot bot
        @world.updateTubes()
                
        post.emit 'botCreated', bot
                
    #  0000000  00000000  000   000  0000000    
    # 000       000       0000  000  000   000  
    # 0000000   0000000   000 0 000  000   000  
    #      000  000       000  0000  000   000  
    # 0000000   00000000  000   000  0000000    
    
    sendPacket: (bot) =>
        
        stone = @world.stoneBelowBot bot
        if @world.storage.canTake stone
            if bot.path?
                if @world.tubes.insertPacket bot
                    @world.storage.willSend stone
                    return true
            else if bot.type == Bot.base
                @world.storage.add stone
                gained = [0,0,0,0]
                gained[stone] = 1
                @world.spent.gainAtPosFace gained, bot.pos, bot.face
                return true
                        
    # 0000000    000   000  000  000      0000000    
    # 000   000  000   000  000  000      000   000  
    # 0000000    000   000  000  000      000   000  
    # 000   000  000   000  000  000      000   000  
    # 0000000     0000000   000  0000000  0000000    
    
    buildBotHit: (bot, hit) ->
             
        if not bot.path
            log 'no path'
            return 
        
        normal = hit.norm.applyQuaternion bot.mesh.quaternion
        hitpos = bot.pos.to hit.point

        n = Vector.closestNormal hitpos
        newFace = Vector.normals.indexOf n
        newPos = bot.pos.plus n
        if @world.stoneAtPos(newPos)?
            log 'occupied negate'
            n.negate()
            newFace = (newFace+3) % 6
            newPos = bot.pos.plus n
            
        if @world.stoneAtPos(newPos)? or @world.botAtPos(newPos)?
            log 'target occupied'
            return
        
        if @world.storage.deductBuild()
            # log newPos, Face.string newFace
            rts.camera.focusOnPos rts.camera.center.plus n
            @world.addStone bot.pos.x, bot.pos.y, bot.pos.z
            @world.spent.costAtBot state.science.build.cost, bot
            @world.moveBot bot, newPos, newFace
            @world.construct.stones()
        else
            log 'cant build'

    # 00     00   0000000   000   000  00000000  
    # 000   000  000   000  000   000  000       
    # 000000000  000   000   000 000   0000000   
    # 000 0 000  000   000     000     000       
    # 000   000   0000000       0      00000000  
    
    moveBot: (bot, pos, face) ->
        
        wbot = @world.botAtPos(pos)
        if not wbot or wbot == bot
            index = @world.indexAtPos pos
            if bot.face != face or bot.index != index
                @world.moveBot bot, pos, face
                @world.highlightPos bot.pos
            
module.exports = Handle
