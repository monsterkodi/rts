###
000   000   0000000   000   000  0000000    000      00000000
000   000  000   000  0000  000  000   000  000      000     
000000000  000000000  000 0 000  000   000  000      0000000 
000   000  000   000  000  0000  000   000  000      000     
000   000  000   000  000   000  0000000    0000000  00000000
###

{ post, log, str, _ } = require 'kxk'

{ Face, Bot, Stone } = require './constants'

Vector = require './lib/vector'

class Handle

    constructor: (@world) ->
        
    botClicked: (bot) -> 
    
        hit = rts.castRay()
        
        switch hit?.bot?.type 
            when Bot.build then @buildBotHit bot, hit

    delay: (delta, bot, prop, func) ->

        prop.delay -= delta
        if prop.delay < 0
            if func bot
                prop.delay += 1/prop.speed
            else
                prop.delay = 0
            
    tickBot: (delta, bot) ->
        
        @delay delta, bot, bot.mine, @sendPacket
            
        storage = @world.storage
        
        switch bot.type 
            when Bot.base
                @delay delta, bot, bot.prod, =>
                    if storage.canTake Stone.red
                        storage.add Stone.red
                    if storage.canTake Stone.gelb
                        storage.add Stone.gelb
                    true
            when Bot.trade
                @tickTrade delta, bot
                
    tickTrade: (delta, bot) ->
        
        if state.trade.state == 'on'
            storage = @world.storage
            @delay delta, bot, bot.trade, =>
                sellStone  = state.trade.sell.stone
                sellAmount = state.trade.sell[Stone.string sellStone]
                if storage.has sellStone, sellAmount
                    buyStone  = state.trade.buy.stone
                    if storage.canTake buyStone
                        # log "trade #{sellAmount} #{Stone.string sellStone} for 1 #{Stone.string buyStone}"
                            
                        if @world.tubes.insertPacket bot, buyStone
                            @world.storage.willSend buyStone
                            storage.sub sellStone, sellAmount
                            cost = [0,0,0,0]
                            cost[sellStone] = sellAmount
                            @costSpentAtPosFace cost, bot.pos, bot.face
                            true
        
    costSpentAtPosFace: (cost, pos, face) ->
        
        # log 'costSpentAtPosFace', cost, pos, Face.string face
                            
    buyBot: (type) ->
        
        [p, face] = @world.emptyPosFaceNearBot @world.base
        if not p?
            log 'WARNING handle.buyBot -- no space for new bot!'
            return
        # log "handle.buyBot #{Bot.string type}"
        cost = state.cost[Bot.string type]
        @world.storage.deduct cost
        @costSpentAtPosFace cost, p, face
        bot = @world.addBot p.x,p.y,p.z, type, face
        @world.construct.botAtPos bot, p
        rts.camera.focusOnPos p
        @world.highlightBot bot
        @world.updateTubes()
        post.emit 'botCreated', bot
                
    sendPacket: (bot) =>
        
        stone = @world.stoneBelowBot bot
        if @world.storage.canTake stone
            if bot.path?
                if @world.tubes.insertPacket bot
                    @world.storage.willSend stone
                    return true
            else if bot.type == Bot.base
                @world.storage.add stone
                return true
                        
    buildBotHit: (bot, hit) ->
        
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
        
        if @world.storage.canBuild()
            log newPos, Face.string newFace
            rts.camera.focusOnPos rts.camera.center.plus n
            @world.addStone bot.pos.x, bot.pos.y, bot.pos.z
            @world.moveBot bot, newPos, newFace
            @world.construct.stones()
        else
            log 'cant build'

    moveBot: (bot, pos, face) ->
        
        wbot = @world.botAtPos(pos)
        if not wbot or wbot == bot
            index = @world.indexAtPos pos
            if bot.face != face or bot.index != index
                @world.moveBot bot, pos, face
                @world.highlightPos bot.pos
            
module.exports = Handle
