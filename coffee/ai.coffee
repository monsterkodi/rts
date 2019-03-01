###
 0000000   000
000   000  000
000000000  000
000   000  000
000   000  000
###

{ first, last, valid, empty, str, log, _ } = require 'kxk'

{ Bot, Stone } = require './constants'

Science = require './science'
Vector = require './lib/vector'

class AI

    constructor: (@world, @base) ->
        
        @scienceOrder = [
            'base.speed'
            'base.prod'
            'trade.sell'
            'mine.speed'
            'mine.limit'
            'path.length'
            'tube.free'
            'build.cost'
            'base.radius'
            'brain.speed'
            'tube.speed'
            'tube.gap'
            'trade.speed'
            'storage.capacity'
            'base.speed'
            'base.prod'
            'trade.sell'
            'mine.speed'
            'mine.limit'
            'path.length'
            'tube.free'
            'build.cost'
            'base.radius'
            'brain.speed'
            'tube.speed'
            'tube.gap'
            'trade.speed'
            'storage.capacity'
            'base.speed'
            'base.prod'
            'trade.sell'
            'mine.speed'
            'mine.limit'
            'path.length'
            'tube.free'
            'build.cost'
            'base.radius'
            'brain.speed'
            'tube.speed'
            'tube.gap'
            'trade.speed'
            'storage.capacity'
            'base.speed'
            'base.prod'
            'mine.speed'
            'mine.limit'
            'path.length'
            'tube.free'
            'build.cost'
            'base.radius'
            'brain.speed'
            'tube.speed'
            'tube.gap'
            'trade.speed'
            'storage.capacity'
            'base.speed'
            'base.prod'
            'mine.speed'
            'mine.limit'
            'path.length'
            'tube.free'
            'build.cost'
            'base.radius'
            'brain.speed'
            'tube.speed'
            'tube.gap'
            'trade.speed'
            'storage.capacity'
        ]
        @player = @base.player
        @actionDelay = state.ai.delay
        @actionQueue = []
        
    #  0000000   000   000  000  00     00   0000000   000000000  00000000  
    # 000   000  0000  000  000  000   000  000   000     000     000       
    # 000000000  000 0 000  000  000000000  000000000     000     0000000   
    # 000   000  000  0000  000  000 0 000  000   000     000     000       
    # 000   000  000   000  000  000   000  000   000     000     00000000  
    
    animate: (scaledDelta) -> 
    
        @actionDelay -= scaledDelta
        return if @actionDelay > 0
        @actionDelay += state.ai.delay
        
        return if @dequeueAction()
        return if @moveToTarget()
        return if @moveToResource()
        return if @buyBot()
        return if @switchBase()
        return if @tradeSurplus()
        return if @doScience()
        
        log "idle #{@player}"
    
    brain: -> @world.botOfType Bot.brain, @player
        
    doScience: ->
        
        if empty @scienceOrder
            log 'no science left?'
            return false
            
        if brain = @brain()
            if @amountOf(@lowestStone()) > 8
                brain.state = 'on'
                if Science.queue[@player].length < Science.maxQueue
                    scienceKey = @scienceOrder.shift()
                    # log 'doScience', scienceKey
                    Science.enqueue scienceKey, @player
                return true
            else
                brain.state = 'off'
                return true
        
    # 0000000     0000000    0000000  00000000  
    # 000   000  000   000  000       000       
    # 0000000    000000000  0000000   0000000   
    # 000   000  000   000       000  000       
    # 0000000    000   000  0000000   00000000  
    
    switchBase: ->
        
        if @amountOf(Stone.red) > 40
            if @base.state == 'off'
                @base.state = 'on'
                log 'base.on'
                return true
        else if @base.state == 'on'
            @base.state = 'off'
            log 'base.off'
            return true
        
    #  0000000   000   000  00000000  000   000  00000000  
    # 000   000  000   000  000       000   000  000       
    # 000 00 00  000   000  0000000   000   000  0000000   
    # 000 0000   000   000  000       000   000  000       
    #  00000 00   0000000   00000000   0000000   00000000  
    
    dequeueAction: ->
        
        if action = @actionQueue.shift()
            action()
            true
        
    # 00000000   00000000   0000000   0000000   000   000  00000000    0000000  00000000  
    # 000   000  000       000       000   000  000   000  000   000  000       000       
    # 0000000    0000000   0000000   000   000  000   000  0000000    000       0000000   
    # 000   000  000            000  000   000  000   000  000   000  000       000       
    # 000   000  00000000  0000000    0000000    0000000   000   000   0000000  00000000  
    
    moveToResource: ->
        
        if @world.noResourceBelowBot @base
            info = @world.emptyResourceNearBot @base
            if valid info.resource
                rts.handle.moveBotToFaceIndex @base, first info.resource
                @actionQueue.push @call
                return true
            else
                return @searchForResource()
        false
        
    #  0000000  00000000   0000000   00000000    0000000  000   000  
    # 000       000       000   000  000   000  000       000   000  
    # 0000000   0000000   000000000  0000000    000       000000000  
    #      000  000       000   000  000   000  000       000   000  
    # 0000000   00000000  000   000  000   000   0000000  000   000  
    
    searchForResource: ->
        
        build = @world.botOfType Bot.build, @player
        return if not build
           
        faceIndices = @world.emptyResources sortPos:build.pos
        if valid faceIndices
            @target = first faceIndices
            @moveBotToFaceClosestToTarget build
            return true
            
        @moveToHuntingSpot()
        
    moveToHuntingSpot: ->
        
        if monster = @world.monsterClosestToPos @base.pos
            # log 'hunt', monster.pos
            return @moveBotToFaceClosestToPos @base, monster.pos
        else
            log "no monster close to #{str @base.pos}?"
        false
    
    # 00     00   0000000   000   000  00000000  
    # 000   000  000   000  000   000  000       
    # 000000000  000   000   000 000   0000000   
    # 000 0 000  000   000     000     000       
    # 000   000   0000000       0      00000000  
    
    moveBotToFaceClosestToPos: (bot, pos) ->
        
        sourceFaceIndex  = @world.faceIndex bot.face, @world.indexAtPos bot.pos
        shorterPathFound = true
        closestFaceIndex = @world.faceIndexClosestToPosReachableFromFaceIndex pos, sourceFaceIndex
        
        if closestFaceIndex
            rts.handle.moveBotToFaceIndex bot, closestFaceIndex
            true
    
    moveBotToFaceClosestToTarget: (bot) ->
        
        sourceFaceIndex  = @world.faceIndex bot.face, @world.indexAtPos bot.pos
        shorterPathFound = true
        closestFaceIndex = @world.faceIndexClosestToFaceIndexReachableFromFaceIndex @target, sourceFaceIndex
        
        while shorterPathFound

            shorterPathFound = false
            
            if not closestFaceIndex
                log 'moveBotToFaceClosestToTarget -- dafuk, no closestFaceIndex!'
                return
            
            targetNeighbors  = @world.neighborsOfFaceIndex @target
            closestNeighbors = @world.neighborsOfFaceIndex closestFaceIndex
            
            targetNeighbors.push  @target
            closestNeighbors.push closestFaceIndex
            
            targetPath = @world.pathFromPosToPos @world.posAtIndex(closestFaceIndex), @world.posAtIndex(@target)
            if not targetPath
                log 'really? no targetPath?'
                break
            
            for targetNeighbor in targetNeighbors
                for closestNeighbor in closestNeighbors
                    closestPath = @world.pathFromPosToPos @world.posAtIndex(closestNeighbor), @world.posAtIndex(targetNeighbor)
                    if not closestPath
                        log 'really? not closestPath?'
                        break
                    if closestPath.length < targetPath.length
                        shorterPathFound = true
                        @target = targetNeighbor
                        closestFaceIndex = closestNeighbor
        
        if closestFaceIndex
            rts.handle.moveBotToFaceIndex bot, closestFaceIndex
        
    # 000000000   0000000   00000000    0000000   00000000  000000000  
    #    000     000   000  000   000  000        000          000     
    #    000     000000000  0000000    000  0000  0000000      000     
    #    000     000   000  000   000  000   000  000          000     
    #    000     000   000  000   000   0000000   00000000     000     
    
    moveToTarget: ->
        
        return if not @target
        
        if not @world.storage[@player].canAfford science(@player).build.cost
            @buyStone Stone.white
            return true

        @stopBuyingStone Stone.white
            
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
            
        if not nextPos
            log 'dafuk -- no nextPos?'
            return false
                    
        n = Vector.normalIndex build.pos.to nextPos
        rts.handle.build build, Vector.normals[n]
        # log 'built to', nextPos
        if path.length < 2
            # log 'target reached!'
            delete @target
        true
        
    # 000000000  00000000    0000000   0000000    00000000  
    #    000     000   000  000   000  000   000  000       
    #    000     0000000    000000000  000   000  0000000   
    #    000     000   000  000   000  000   000  000       
    #    000     000   000  000   000  0000000    00000000  

    trade: -> @world.botOfType Bot.trade, @player
    amountOf: (stone) -> @world.storage[@player].stones[stone]
    storageCapacity: -> science(@player).storage.capacity
    
    amountsExcept: (exceptStone) ->
        
        stones = Stone.resources.filter (s) -> s != exceptStone
        amounts = stones.map (stone) => stone:stone, amount:@amountOf(stone)
        amounts.sort (a,b) -> a.amount-b.amount
        amounts
        
    lowestStoneExceptStone: (exceptStone) -> first(@amountsExcept exceptStone).stone
    highestStoneExceptStone: (exceptStone) -> last(@amountsExcept exceptStone).stone
        
    highestStone: -> @highestStoneExceptStone Stone.gray
    lowestStone:  -> @lowestStoneExceptStone  Stone.gray
        
    tradeSurplus: ->
        
        if trade = @trade()
            for stone in Stone.resources
                if @amountOf(stone) == @storageCapacity()
                    buyStone = @lowestStoneExceptStone stone
                    if @amountOf(buyStone) < @storageCapacity()-4
                        # log "trade surplus #{Stone.string stone} for #{Stone.string buyStone}"
                        @buyStone buyStone
                        return true
                        
            if trade.state == 'on'
                if @amountOf(trade.sell) <= Math.max 40, @amountOf(trade.buy) - 16
                    @stopBuyingStone trade.buy
                    # log "stop trade surplus"
                    return true
                    
                if @amountOf(trade.sell) < @amountOf(@highestStone()) - 16
                    @buyStone trade.buy
                    # log "switch trade surplus"
                    return true
                
    buyStone: (stone) ->
        
        if trade = @trade()
            trade.buy = stone
            trade.sell = @highestStoneExceptStone stone
            trade.state = 'on'

    stopBuyingStone: (stone) ->
        
        if trade = @trade()
            if trade.buy == stone
                trade.state = 'off'
            
    # 0000000    000   000  000   000  0000000     0000000   000000000  
    # 000   000  000   000   000 000   000   000  000   000     000     
    # 0000000    000   000    00000    0000000    000   000     000     
    # 000   000  000   000     000     000   000  000   000     000     
    # 0000000     0000000      000     0000000     0000000      000     
    
    buyBot: ->
        
        # for bot in [Bot.mine, Bot.trade, Bot.brain, Bot.build]
        for bot in [Bot.mine, Bot.trade, Bot.build, Bot.brain]
            if not @world.botOfType bot, @player
                if rts.handle.buyBot bot, @player
                    @actionQueue.push @call
                    return true
        false
        
    call: => rts.handle.call @player
                            
module.exports = AI
