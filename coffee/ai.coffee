###
 0000000   000
000   000  000
000000000  000
000   000  000
000   000  000
###

{ post, first, last, valid, empty, str, log, _ } = require 'kxk'

{ Bot, Stone } = require './constants'

Science = require './science'
Vector = require './lib/vector'

class AI

    constructor: (@world, @base) ->
        
        @brain = null
        @trade = null
        @build = null
        
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
            'berta.limit'
            'berta.speed'
            'berta.radius'
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
            'berta.limit'
            'berta.speed'
            'berta.radius'
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
            'berta.limit'
            'berta.speed'
            'berta.radius'            
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
            'berta.limit'
            'berta.speed'
            'berta.radius'            
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
            'berta.limit'
            'berta.speed'
            'berta.radius'
        ]
        
        @tick = 0
        @task = ''
        @player = @base.player
        @actionDelay = state.ai.delay
        @actionQueue = []
        
        post.on 'botRemoved', @onBotRemoved
        
    onBotRemoved: (type, player) =>
        
        if player == @player
            switch type
                when @brain then @brain = null
                when @trade then @trade = null
                when @build then @build = null
                when @base  then @base  = null
        
    #  0000000   000   000  000  00     00   0000000   000000000  00000000  
    # 000   000  0000  000  000  000   000  000   000     000     000       
    # 000000000  000 0 000  000  000000000  000000000     000     0000000   
    # 000   000  000  0000  000  000 0 000  000   000     000     000       
    # 000   000  000   000  000  000   000  000   000     000     00000000  
    
    animate: (scaledDelta) -> 
    
        @actionDelay -= scaledDelta
        return if @actionDelay > 0
        @actionDelay += state.ai.delay
        @tick++
        return if @dequeueAction()
        return if @moveToTarget()
        return if @moveToResource()
        return if @buyBot()
        return if @switchBase()
        return if @switchBerta()
        return if @tradeSurplus()
        return if @doScience()
        return if @idleCall()
        @did 'relax'
    
    did: (@task) -> log "#{@player} #{@tick} #{@task}"; true
    queue: (action) -> @actionQueue.push action
        
    #  0000000   0000000  000  00000000  000   000   0000000  00000000  
    # 000       000       000  000       0000  000  000       000       
    # 0000000   000       000  0000000   000 0 000  000       0000000   
    #      000  000       000  000       000  0000  000       000       
    # 0000000    0000000  000  00000000  000   000   0000000  00000000  
    
    doScience: ->
        
        if empty @scienceOrder
            log 'no science left?'
            return false
            
        if @brain
            if @amountOf(@lowestStone()) > 8
                if @brain.state == 'off'
                    rts.handle.toggleBotState @brain
                if Science.queue[@player].length < Science.maxQueue
                    scienceKey = @scienceOrder.shift()
                    # log 'doScience', scienceKey
                    Science.enqueue scienceKey, @player
                    return @did "queue:#{scienceKey}"
            else
                if @brain.state == 'on'
                    rts.handle.toggleBotState @brain
                    return @did 'brain:off'
                    
    # 0000000     0000000    0000000  00000000  
    # 000   000  000   000  000       000       
    # 0000000    000000000  0000000   0000000   
    # 000   000  000   000       000  000       
    # 0000000    000   000  0000000   00000000  
    
    switchBase: ->
        
        sparkStones = @amountOf state.spark.stone
        
        if sparkStones > 40
            if @base.state == 'off'
                rts.handle.toggleBotState @base
                return @did 'base:on'
                
        if sparkStones < 10 and @base.state == 'on' and @brain?.state == 'on'
            rts.handle.toggleBotState @base
            return @did 'base:off'
        
    switchBerta: ->

        bertas = @world.botsOfType Bot.berta, @player
        
        if valid bertas
        
            bulletStones = @amountOf state.bullet.stone
            
            if bulletStones > 40
                if bertas[0].state == 'off'
                    rts.handle.toggleBotState bertas[0]
                    return @did 'berta:on'
                    
            if bulletStones < 10 and bertas[0].state == 'on' and @brain?.state == 'on'
                rts.handle.toggleBotState bertas[0]
                return @did 'berta:off'
        
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
                if rts.handle.moveBotToFaceIndex @base, first info.resource
                    @queue @call
                    return @did "move base:#{@world.stringForFaceIndex first info.resource}"
            else
                @queue @searchForResource
        false
        
    #  0000000  00000000   0000000   00000000    0000000  000   000  
    # 000       000       000   000  000   000  000       000   000  
    # 0000000   0000000   000000000  0000000    000       000000000  
    #      000  000       000   000  000   000  000       000   000  
    # 0000000   00000000  000   000  000   000   0000000  000   000  
    
    searchForResource: =>
        
        if @build
           
            faceIndices = @world.emptyResources sortPos:@build.pos
            if valid faceIndices
                @target = first faceIndices
                @did "set target resource to #{@world.stringForFaceIndex @target}"
                if @moveBotToFaceClosestToTarget @build
                    @did "move build closer #{@world.stringForFaceIndex @world.faceIndexForBot @build}"
                    return @did 'search for resource'
            
        @queue @moveToHuntingSpot
        false
        
    moveToHuntingSpot: =>
        
        if monster = @world.monsterClosestToPos @base.pos
            if @moveBotToFaceClosestToPos @base, monster.pos
                if @base.state == 'off'
                    rts.handle.toggleBotState @base
                    @did 'base:on'
                if @brain?.state == 'on'
                    rts.handle.toggleBotState @brain
                    @did 'brain:off'
                return @did 'hunt'
        else
            log "no monster close to #{str @base.pos}?"
        false
    
    # 00     00   0000000   000   000  00000000  
    # 000   000  000   000  000   000  000       
    # 000000000  000   000   000 000   0000000   
    # 000 0 000  000   000     000     000       
    # 000   000   0000000       0      00000000  
    
    moveBotToFaceClosestToPos: (bot, pos) ->
        
        sourceFaceIndex  = @world.faceIndex bot.face, @world.indexAtBot bot
        shorterPathFound = true
        closestFaceIndex = @world.faceIndexClosestToPosReachableFromFaceIndex pos, sourceFaceIndex
        
        if closestFaceIndex
            return rts.handle.moveBotToFaceIndex bot, closestFaceIndex
        else 
            log 'no closestFace'
    
    moveBotToFaceClosestToTarget: (bot) ->
        
        sourceFaceIndex  = @world.faceIndexForBot bot
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
                return
            
            for targetNeighbor in targetNeighbors
                for closestNeighbor in closestNeighbors
                    closestPath = @world.pathFromPosToPos @world.posAtIndex(closestNeighbor), @world.posAtIndex(targetNeighbor)
                    if not closestPath
                        log "really? not closestPath? closestNeighbor:#{@world.stringForIndex closestNeighbor} targetNeighbor:#{@world.stringForIndex targetNeighbor}"
                        break
                    if closestPath.length < targetPath.length
                        shorterPathFound = true
                        @target = targetNeighbor
                        closestFaceIndex = closestNeighbor
        
        if closestFaceIndex
            log "closestFaceIndex #{@world.stringForFaceIndex closestFaceIndex}"
            return rts.handle.moveBotToFaceIndex bot, closestFaceIndex
        
    # 000000000   0000000   00000000    0000000   00000000  000000000  
    #    000     000   000  000   000  000        000          000     
    #    000     000000000  0000000    000  0000  0000000      000     
    #    000     000   000  000   000  000   000  000          000     
    #    000     000   000  000   000   0000000   00000000     000     
    
    moveToTarget: ->
        
        return if not @target
        return if not @build
        
        targetPos = @world.posAtIndex @target
        if targetPos.equals @build.pos
            choices = Vector.perpNormals(Vector.normals[@build.face]).filter (n) => @world.noItemAtPos @build.pos.plus n
            log "target reached. #{choices.length} choices"
            delete @target
            if valid choices
                if rts.handle.build @build, first choices
                    return @did "build #{@world.stringForFaceIndex @world.faceIndexForBot @build}"
            log "couldn't build last stone!"
            return
        
        if not @world.storage[@player].canAfford science(@player).build.cost
            return @buyStone Stone.white

        @stopBuyingStone Stone.white

        path = @world.pathFromPosToPos @build.pos, targetPos
        
        if not path
            log 'moveToTarget dafuk? no path?', @build.pos, @world.posAtIndex @target
            delete @target
            return false
        
        if path.length >= 2
            nextPos = @world.posAtIndex path[1]
        else
            for n in Vector.perpNormals Vector.normals[@build.face]
                nextPos = @build.pos.plus n
                if @world.noItemAtPos nextPos
                    break
            
        if not nextPos
            log 'dafuk -- no nextPos?'
            return false
                    
        n = Vector.normalIndex @build.pos.to nextPos
        if rts.handle.build @build, Vector.normals[n]
            # log 'built to', nextPos
            if path.length < 2
                log 'target reached!'
                delete @target
            return @did "build #{@world.stringForFaceIndex @world.faceIndexForBot @build}"
            
        false
        
    # 000000000  00000000    0000000   0000000    00000000  
    #    000     000   000  000   000  000   000  000       
    #    000     0000000    000000000  000   000  0000000   
    #    000     000   000  000   000  000   000  000       
    #    000     000   000  000   000  0000000    00000000  

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
        
        if @trade
            for stone in Stone.resources
                if @amountOf(stone) == @storageCapacity()
                    buyStone = @lowestStoneExceptStone stone
                    if @amountOf(buyStone) < @storageCapacity()-4
                        # log "trade surplus #{Stone.string stone} for #{Stone.string buyStone}"
                        return @buyStone buyStone
                        
            if @trade.state == 'on'
                if @amountOf(@trade.sell) <= Math.max 40, @amountOf(@trade.buy) - 16
                    return @stopBuyingStone @trade.buy
                    
                if @amountOf(@trade.sell) < @amountOf(@highestStone()) - 16
                    return @buyStone @trade.buy
        false
                
    buyStone: (stone) ->
        
        if @trade
            
            if @trade.buy != stone or @trade.state == 'off'
                rts.handle.toggleBotState @trade
                @trade.buy = stone
                @trade.sell = @highestStoneExceptStone stone
                return @did "buy #{Stone.string stone} for #{Stone.string @trade.sell}"
        false

    stopBuyingStone: (stone) ->
        
        if @trade
            
            if @trade.buy == stone and @trade.state == 'on'
                rts.handle.toggleBotState @trade
                return @did "stop buying #{Stone.string stone}"
        false
            
    # 0000000    000   000  000   000  0000000     0000000   000000000  
    # 000   000  000   000   000 000   000   000  000   000     000     
    # 0000000    000   000    00000    0000000    000   000     000     
    # 000   000  000   000     000     000   000  000   000     000     
    # 0000000     0000000      000     0000000     0000000      000     
    
    buyBot: ->
        
        for bot in [Bot.mine, Bot.trade, Bot.brain, Bot.build]
            if not @world.botOfType bot, @player
                if newBot = rts.handle.buyBot bot, @player
                    if bot != Bot.mine
                        @[Bot.string bot] = newBot
                    @queue @call
                    return @did "buy #{Bot.string bot}"
                    
        if @world.botsOfType(Bot.mine, @player).length < science(@player).mine.limit
            if rts.handle.buyBot Bot.mine, @player
                @queue @call
                return @did "buy #{Bot.string Bot.mine}"
                
        if @world.botsOfType(Bot.berta, @player).length < science(@player).berta.limit
            if rts.handle.buyBot Bot.berta, @player
                @queue @call
                return @did "buy #{Bot.string Bot.berta}"
            
        false
    
    idleCall: ->

        return if @target
        if rts.handle.call @player, {moveWhenOnResource:true, moveBuild:not @target}
            @did 'idle call'
        
    call: => 
        
        if rts.handle.call @player, {moveWhenOnResource:true, moveBuild:not @target}
            @did 'call'
                            
module.exports = AI
