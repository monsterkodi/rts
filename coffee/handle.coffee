###
000   000   0000000   000   000  0000000    000      00000000
000   000  000   000  0000  000  000   000  000      000
000000000  000000000  000 0 000  000   000  000      0000000
000   000  000   000  000  0000  000   000  000      000
000   000  000   000  000   000  0000000    0000000  00000000
###

{ post, empty, valid, log, str, _ } = require 'kxk'

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
        if state.science.tube.free < 2
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
        if state.science.tube.free < 3
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
        # log 'send', Stone.string stone
        if @world.storage.canTake stone
            if bot.path?
                if @world.tubes.insertPacket bot, stone
                    @world.storage.willSend stone
                    if resource = @world.resourceAtPos @world.posBelowBot bot
                        resource.deduct()
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
    
    canBuild: (norm) ->
        
        buildBot = @world.botOfType Bot.build
        
        return false if not buildBot
        return false if not @world.storage.canAfford state.science.build.cost
        
        if state.science.tube.free < 1
            if not buildBot.path
                return false
                
        if norm and @world.isItemAtPos buildBot.pos.plus norm
            return false
            
        true
        
    buildBotHit: (bot, hit) ->

        return if not @canBuild()
        
        if hitInfo = @infoForBuildHit bot, hit
                
            if @world.storage.deductBuild()

                rts.camera.focusOnPos rts.camera.center.plus hitInfo.norm

                @world.addStone bot.pos.x, bot.pos.y, bot.pos.z
                @world.spent.costAtBuild state.science.build.cost, bot
                @world.moveBot bot, hitInfo.pos, hitInfo.face
                @world.construct.stones()
                if @canBuild hitInfo.norm
                    @world.showBuildGuide bot, hitInfo
            else
                @world.removeBuildGuide()
                log 'not enough stones'
    
    # 00     00   0000000   000   000  00000000        000   000  000  000000000  
    # 000   000  000   000  000   000  000             000   000  000     000     
    # 000000000  000   000   000 000   0000000         000000000  000     000     
    # 000 0 000  000   000     000     000             000   000  000     000     
    # 000   000   0000000       0      00000000        000   000  000     000     
    
    mouseMoveHit: (hit) ->
        
        @world.removeBuildGuide()
        
        if hit and hit.bot?
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

    moveBot: (bot, pos, face) ->

        wbot = @world.botAtPos(pos)
        if not wbot or wbot == bot
            index = @world.indexAtPos pos
            if bot.face != face or bot.index != index
                if @world.canBotMoveTo bot, face, index
                    @world.moveBot bot, pos, face
                    @world.highlightPos bot.pos

    monsterMoved: (monster) ->

        return if state.base.state == 'off'
        if Math.round(monster.pos.manhattan(@world.base.pos)) <= state.science.base.radius
            Spark.spawn @world, @world.base.pos, monster

    call: ->
        
        info = @world.emptyResourceNearBase()
        
        for type in [Bot.mine, Bot.brain, Bot.trade, Bot.build]
            for bot in @world.botsOfType type
                if @world.stoneBelowBot(bot) not in Stone.resources or not bot.path

                    if valid info.resource
                        faceIndex = info.resource.shift()
                        [face, index] = @world.splitFaceIndex faceIndex
                        pos = @world.posAtIndex index
                        @moveBot bot, pos, face
                    else if valid info.empty
                        faceIndex = info.empty.shift()
                        [face, index] = @world.splitFaceIndex faceIndex
                        pos = @world.posAtIndex index
                        @moveBot bot, pos, face
                    else
                        log 'no resource or empty pos'
            
module.exports = Handle
