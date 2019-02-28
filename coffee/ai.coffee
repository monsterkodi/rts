###
 0000000   000
000   000  000
000000000  000
000   000  000
000   000  000
###

{ first, last, valid, empty, str, log, _ } = require 'kxk'

{ Bot, Stone } = require './constants'

Vector = require './lib/vector'

class AI

    constructor: (@world, @base) ->
        
        @player = @base.player
        @actionDelay = state.ai.delay
        
    animate: (scaledDelta) -> 
    
        @actionDelay -= scaledDelta
        return if @actionDelay > 0
        @actionDelay += state.ai.delay
        
        return if @moveToTarget()
        return if @moveToResource()
        return if @buyBot()
        log "idle #{@player}"
        
    moveToResource: ->
        
        if @world.noResourceBelowBot @base
            info = @world.emptyResourceNearBot @base
            if valid info.resource
                rts.handle.moveBotToFaceIndex @base, first info.resource
                rts.handle.call @player
                return true
            else
                return @searchForResource()
                # log "no resources available #{@player}"#, info
        false
        
    searchForResource: ->
        
        build = @world.botOfType Bot.build, @player
        return if not build
            
        if faceIndices = @world.emptyResources(sortPos:build.pos)
            @target = first faceIndices
            @moveBotToFaceClosestToTarget build, @target
            return true
        false
    
    moveBotToFaceClosestToTarget: (bot, target) ->
        # log "moveBotToFaceClosestToTarget #{str target} #{str bot.pos} #{bot.face}"
        if faceIndex = @world.faceIndexClosestToFaceIndexReachableFromPosFace target, bot.pos, bot.face
            log "path from #{str @world.posAtIndex faceIndex} to target #{@world.stringForFaceIndex target}:", @world.pathFromPosToPos @world.posAtIndex(faceIndex), @world.posAtIndex target
            log "closestFaceIndex #{faceIndex}", @world.stringForFaceIndex faceIndex
            rts.handle.moveBotToFaceIndex bot, faceIndex
        
    moveToTarget: ->
        
        return if not @target
        
        if not @world.storage[@player].canAfford state.science.build.cost
            @buyStone Stone.white
            return true

        build = @world.botOfType Bot.build, @player
        path = @world.pathFromPosToPos build.pos, @world.posAtIndex @target
        
        if empty path
            log 'dafuk? no path?'
            return false
        
        if path.length >= 2
            nextPos = @world.posAtIndex path[1]
        else
            for n in Vector.perpNormals Vector.normals[build.face]
                nextPos = build.pos.plus n
                if @world.noItemAtPos nextPos
                    break
            log 'lastPos', nextPos
        if not nextPos
            log 'no nextPos?'
            return false
                    
        n = Vector.normalIndex build.pos.to nextPos
        rts.handle.build build, Vector.normals[n]
        log 'built to', nextPos
        if path.length < 2
            log 'target reached!'
            delete @target
        true
        
    buyStone: (stone) ->
        
        # log "buyStone #{Stone.string stone}"
        if trade = @world.botOfType Bot.trade, @player
            trade.buy = stone
            sellable = Stone.resources.filter (s) -> s != stone
            stoneAmounts = sellable.map (s) => stone:s, amount:@world.storage[@player].stones[s]
            stoneAmounts.sort (a,b) -> b.amount-a.amount
            trade.sell = first(stoneAmounts).stone
            # log "sell #{Stone.string trade.sell}"
            trade.state = 'on'
            
    buyBot: ->
        
        # for bot in [Bot.mine, Bot.trade, Bot.brain, Bot.build]
        for bot in [Bot.mine, Bot.trade, Bot.build, Bot.brain]
            if not @world.botOfType bot, @player
                rts.handle.buyBot bot, @player
                return true
        false
                            
module.exports = AI
