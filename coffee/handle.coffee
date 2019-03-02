###
000   000   0000000   000   000  0000000    000      00000000
000   000  000   000  0000  000  000   000  000      000
000000000  000000000  000 0 000  000   000  000      0000000
000   000  000   000  000  0000  000   000  000      000
000   000  000   000  000   000  0000000    0000000  00000000
###

{ post, empty, valid, first, log, str, _ } = require 'kxk'

{ Face, Bot, Stone } = require './constants'

Science = require './science'
Spark  = require './spark'
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

        bot[delay] -= delta
        if bot[delay] <= 0
            if func bot
                if speed == 'mine'
                    s = Science.mineSpeed bot
                else
                    s = science(bot.player)[Bot.string bot.type][speed]
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
            when Bot.berta then @tickBerta delta, bot

    # 0000000     0000000    0000000  00000000
    # 000   000  000   000  000       000
    # 0000000    000000000  0000000   0000000
    # 000   000  000   000       000  000
    # 0000000    000   000  0000000   00000000

    tickBase: (delta, bot) ->

        @delay delta, bot, 'speed', 'prod', =>
            gained = [0,0,0,0]
            storage = @world.storage[bot.player]
            for stone in Stone.resources
                amount = science(bot.player).base.prod[stone]
                for i in [0...amount]
                    if storage.canTake stone
                        storage.add stone
                        gained[stone] += 1
            @world.spent.gainAtPosFace gained, bot.pos, bot.face
            true
            
    tickBerta: (delta, bot) ->
        
        @delay delta, bot, 'speed', 'shoot', =>
            log 'berta shoot'
            true

    # 0000000    00000000    0000000   000  000   000
    # 000   000  000   000  000   000  000  0000  000
    # 0000000    0000000    000000000  000  000 0 000
    # 000   000  000   000  000   000  000  000  0000
    # 0000000    000   000  000   000  000  000   000

    tickBrain: (delta, bot) ->

        return if bot.state != 'on'
        if science(bot.player).tube.free < 2
            return if not bot.path

        @delay delta, bot, 'speed', 'think', =>

            if cost = Science.currentCost bot.player
                # log "tickBrain #{bot.player}", cost
                storage = @world.storage[bot.player]
                if storage.canAfford cost
                    Science.deduct bot.player
                    storage.deduct cost
                    @world.spent.costAtBot cost, bot
                    true

    # 000000000  00000000    0000000   0000000    00000000
    #    000     000   000  000   000  000   000  000
    #    000     0000000    000000000  000   000  0000000
    #    000     000   000  000   000  000   000  000
    #    000     000   000  000   000  0000000    00000000

    tickTrade: (delta, bot) ->

        return if bot.state != 'on'
        if science(bot.player).tube.free < 3
            return if not bot.path

        @delay delta, bot, 'speed', 'trade', =>

            # log "bot.trade #{bot.player}"
            storage    = @world.storage[bot.player]
            sellStone  = bot.sell
            sellAmount = science(bot.player).trade.sell
            # log "sell #{sellAmount} #{Stone.string sellStone}"
            if storage.has sellStone, sellAmount
                buyStone = bot.buy
                # log "buy #{Stone.string buyStone}"
                if storage.canTake buyStone
                    # log "trade #{bot.player} #{sellAmount} #{Stone.string sellStone} for 1 #{Stone.string buyStone}"
                    if @world.tubes.insertPacket bot, buyStone
                        storage.willSend buyStone
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

    buyBot: (type, player=0) ->

        storage = @world.storage[player]
        cost = state.cost[Bot.string type]
        if not storage.canAfford cost
            if player == 0
                log "WARNING handle.buyBot player:#{player} -- not enough stones for bot!"
            return

        switch type 
            when Bot.mine, Bot.berta
                if @world.botsOfType(type, player).length >= science(player)[Bot.string type].limit
                    log "WARNING handle.buyBot player:#{player} -- #{Bot.string type} limit reached!"
                    return
            else
                if @world.botOfType(type, player)
                    log "WARNING handle.buyBot player:#{player} -- already has a #{Bot.string type}!"
                    return
                    
        [p, face] = @world.emptyPosFaceNearBot @world.bases[player]
        if not p?
            log "WARNING handle.buyBot player:#{player} -- no space for new bot!"
            return

        storage.deduct cost, 'buy'
        bot = @world.addBot p.x,p.y,p.z, type, player, face
        @world.spent.costAtBot cost, bot
        @world.construct.botAtPos bot, p
        @world.updateTubes()
        
        switch type 
            when Bot.brain
                bot.state = 'on'
        
        if player == 0
            rts.camera.focusOnPos p
            @world.highlightBot bot
            post.emit 'botCreated', bot
            
        bot

    #  0000000  00000000  000   000  0000000
    # 000       000       0000  000  000   000
    # 0000000   0000000   000 0 000  000   000
    #      000  000       000  0000  000   000
    # 0000000   00000000  000   000  0000000

    sendPacket: (bot) =>

        stone = @world.stoneBelowBot bot
        # log 'send', Stone.string stone
        storage = @world.storage[bot.player]
        if storage.canTake stone
            if bot.path?
                if @world.tubes.insertPacket bot, stone
                    storage.willSend stone
                    if resource = @world.resourceAtPos @world.posBelowBot bot
                        resource.deduct()
                    return true
            else if bot.type == Bot.base
                storage.add stone
                gained = [0,0,0,0]
                gained[stone] = 1
                @world.spent.gainAtPosFace gained, bot.pos, bot.face
                return true

    # 0000000    000   000  000  000      0000000
    # 000   000  000   000  000  000      000   000
    # 0000000    000   000  000  000      000   000
    # 000   000  000   000  000  000      000   000
    # 0000000     0000000   000  0000000  0000000

    infoForBuildHit: (bot, hit) ->
        
        hitpos = bot.pos.to hit.point

        n = Vector.closestNormal hitpos
        newFace = Vector.normalIndex n
        newPos = bot.pos.plus n
        
        if @world.isStoneAtPos newPos
            n.negate()
            newFace = (newFace+3) % 6
            newPos = bot.pos.plus n

        if @world.isItemAtPos newPos
            return
            
        pos:  newPos
        face: newFace
        norm: n
    
    canBuild: (norm, player=0) ->
        
        buildBot = @world.botOfType Bot.build
        
        storage = @world.storage[player]
        
        return false if not buildBot
        return false if not storage.canAfford science(player).build.cost
        
        if science(player).tube.free < 1
            if not buildBot.path
                return false
                
        if norm and @world.isItemAtPos buildBot.pos.plus norm
            return false
            
        true
        
    buildBotHit: (bot, hit) ->

        return if not @canBuild()
        
        player = 0
        
        if hitInfo = @infoForBuildHit bot, hit

            storage = @world.storage[player]
            if storage.deductBuild()

                rts.camera.focusOnPos rts.camera.center.plus hitInfo.norm

                @world.addStone bot.pos.x, bot.pos.y, bot.pos.z
                @world.spent.costAtBuild science(player).build.cost, bot
                @world.moveBot bot, hitInfo.pos, hitInfo.face
                @world.construct.stones()
                if @canBuild hitInfo.norm
                    @world.showBuildGuide bot, hitInfo
            else
                @world.removeBuildGuide()
                log 'not enough stones'
                
    build: (bot, norm) ->
        
        pos = bot.pos.plus norm
        face = Vector.normalIndex norm

        storage = @world.storage[bot.player]
        if storage.deductBuild()

            @world.addStone bot.pos.x, bot.pos.y, bot.pos.z
            @world.spent.costAtBuild science(bot.player).build.cost, bot
            @world.moveBot bot, pos, face
            @world.construct.stones()
            
            if bot.player == 0
                rts.camera.focusOnPos rts.camera.center.plus norm
                if @canBuild norm
                    @world.showBuildGuide bot, hitInfo
                    
            true
    
    # 00     00   0000000   000   000  00000000        000   000  000  000000000  
    # 000   000  000   000  000   000  000             000   000  000     000     
    # 000000000  000   000   000 000   0000000         000000000  000     000     
    # 000 0 000  000   000     000     000             000   000  000     000     
    # 000   000   0000000       0      00000000        000   000  000     000     
    
    mouseMoveHit: (hit) ->
        
        @world.removeBuildGuide()
        
        if hit and hit.bot? and hit.bot.player == 0
            @world.highlightBot hit.bot
            if hit.bot.type == Bot.build
                if hitInfo = @infoForBuildHit hit.bot, hit
                    if @canBuild hitInfo.norm
                        @world.showBuildGuide hit.bot, hitInfo
        else
            @world.removeHighlight()
            
    placeBase: ->
        
        if hit = rts.castRay true
            if not hit.bot
                @moveBot @world.base, hit.pos, hit.face
                
    placeBuild: ->
        
        if build = @world.botOfType Bot.build
            if hit = rts.castRay true
                if not hit.bot
                    @moveBot build, hit.pos, hit.face
            
    # 00     00   0000000   000   000  00000000
    # 000   000  000   000  000   000  000
    # 000000000  000   000   000 000   0000000
    # 000 0 000  000   000     000     000
    # 000   000   0000000       0      00000000

    moveBotToFaceIndex: (bot, faceIndex) ->
        
        [face, index] = @world.splitFaceIndex faceIndex
        pos = @world.posAtIndex index
        return @moveBot bot, pos, face
        
    moveBot: (bot, pos, face) ->

        if not @world.isItemAtPos(pos) or @world.botAtPos(pos) == bot
            index = @world.indexAtPos pos
            if bot.face != face or bot.index != index
                if @world.canBotMoveTo bot, face, index
                    @world.moveBot bot, pos, face
                    @world.highlightBot bot
                    return true

    monsterMoved: (monster) ->

        for base in @world.bases
            if base.state == 'on'
                if Math.round(monster.pos.manhattan(base.pos)) <= science(base.player).base.radius
                    Spark.spawn @world, base, monster

    call: (player=0, cfg={moveWhenOnResource:true, moveBuild:true}) ->
        
        info = @world.emptyResourceNearBase player
        
        botMoved = false
        baseIndex = @world.faceIndexForBot @world.bases[player]
        for type in [Bot.mine, Bot.brain, Bot.trade, Bot.berta, Bot.build]
            
            if type == Bot.build and not cfg.moveBuild
                break
            
            for bot in @world.botsOfType type, player
                
                isOnResource = @world.isResourceBelowBot bot
                
                if not cfg.moveWhenOnResource and isOnResource
                    log 'dont move on resource'
                    continue
                    
                if faceIndex = first(info.resource) ? first(info.empty)
                    botIndex = @world.faceIndexForBot bot
                    # log "distanceFrom face #{@world.stringForFaceIndex faceIndex} base #{@world.stringForFaceIndex baseIndex} bot #{@world.stringForFaceIndex botIndex}"
                    if ((not isOnResource) and valid(info.resource)) or @world.distanceFromFaceToFace(faceIndex,baseIndex) < @world.distanceFromFaceToFace(botIndex,baseIndex)
                        if valid info.resource then info.resource.shift()
                        else info.empty.shift()
                        moved = @moveBotToFaceIndex bot, faceIndex
                        # log "move:#{Bot.string bot.type}" if moved
                        botMoved = botMoved or moved
                    # else
                        # log "stay:#{Bot.string bot.type} #{@world.distanceFromFaceToFace(faceIndex,baseIndex)} >= #{@world.distanceFromFaceToFace(botIndex,baseIndex)}"
                else
                    log 'no resource and no empty'
        botMoved
            
module.exports = Handle
