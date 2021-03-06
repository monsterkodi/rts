###
000   000   0000000   000   000  0000000    000      00000000
000   000  000   000  0000  000  000   000  000      000
000000000  000000000  000 0 000  000   000  000      0000000
000   000  000   000  000  0000  000   000  000      000
000   000  000   000  000   000  0000000    0000000  00000000
###

Spark     = require './spark'
Bullet    = require './bullet'

class Handle

    constructor: ->

    botButtonClick: (button) ->

        if button.bot == Bot.mine or empty world.botsOfType button.bot
            @buyBot button.bot
        else 
            @toggleBotState world.botOfType button.bot
            # button.focusNextBot()
           
    doubleClick: ->
        
        if world.highBot
            # log 'double', Bot.string(bot.type), world.stringForFaceIndex world.faceIndexForBot bot
            @toggleBotState world.highBot       
        else
            @placeBase()

    toggleBotState: (bot) ->
        
        if bot.type in Bot.switchable
            
            oldState = bot.state
            newState = oldState == 'on' and 'off' or 'on'
            for bot in world. botsOfType bot.type, bot.player
                bot.state = newState
            # log "toggleBotState #{Bot.string(bot.type)} #{bot.player} #{newState}"
            post.emit 'botState', bot.type, newState, bot.player
            playSound 'state', newState, bot.type if bot.player == 0
            newState
            
    #  0000000  000      000   0000000  000   000  
    # 000       000      000  000       000  000   
    # 000       000      000  000       0000000    
    # 000       000      000  000       000  000   
    #  0000000  0000000  000   0000000  000   000  
    
    botClicked: (bot) ->

        hit = rts.castRay()

        switch hit?.bot?.type
            when Bot.build then @buildBotHit bot, hit
            when Bot.icon  
                if world[bot.func]?
                    world.clear()
                    world[bot.func].apply world
                    world.isMeta = false
                    world.create()
                    
    loadMeta: ->
        
        world.clear()
        world.meta()
        world.create()

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

    tickBase: (delta, base) ->
        
        @delay delta, base, 'speed', 'prod', =>
            gained = [0,0,0,0]
            storage = world.storage[base.player]
            for stone in Stone.resources
                amount = science(base.player).base.prod[stone]
                for i in [0...amount]
                    if storage.canTake stone
                        storage.add stone
                        gained[stone] += 1
            world.spent.gainAtPosFace gained, base.pos, base.face
            true
            
    # 0000000    00000000  00000000   000000000   0000000   
    # 000   000  000       000   000     000     000   000  
    # 0000000    0000000   0000000       000     000000000  
    # 000   000  000       000   000     000     000   000  
    # 0000000    00000000  000   000     000     000   000  
    
    tickBerta: (delta, berta) ->
        
        return if berta.state != 'on'
        return if Science.needsTube(berta.type, berta.player) and not berta.path
        
        @delay delta, berta, 'speed', 'shoot', =>
            storage = world.storage[berta.player]
            stone = Stone.gelb
            if berta.player then stone = Stone.red
            if storage.stones[stone]
                if enemy = world.enemyClosestToBot berta
                    if Math.round(enemy.pos.manhattan(berta.pos)) <= science(berta.player).berta.radius
                        # log "shoot at #{berta.player} #{Bot.string enemy.type} #{enemy.player}"
                        Bullet.spawn berta, enemy, stone
                    # else 
                        # log "enemy too far #{berta.player} #{Bot.string enemy.type}"
                # else 
                    # log "no enemy #{berta.player}"
            # else
                # log "no stones #{berta.player}"
            true

    enemyDamage: (enemy, damage) ->
        
        return if not enemy.mesh
        enemy.hitPoints -= damage
        enemy.mesh.material = Materials.stone[Stone.gelb]
        restoreMat = (enemy) -> -> world.colorBot enemy
        setTimeout restoreMat(enemy), 1000*0.5/world.speed
        post.emit 'botDamage', enemy, enemy.hitPoints
        if enemy.hitPoints <= 0
            @enemyDeath enemy

    enemyDeath: (enemy) ->
        
        if enemy.type == Bot.base
            world.removePlayer enemy.player
        else
            world.removeBot enemy
            
    # 0000000    00000000    0000000   000  000   000
    # 000   000  000   000  000   000  000  0000  000
    # 0000000    0000000    000000000  000  000 0 000
    # 000   000  000   000  000   000  000  000  0000
    # 0000000    000   000  000   000  000  000   000

    tickBrain: (delta, brain) ->

        return if brain.state != 'on'
        return if not brain.path

        @delay delta, brain, 'speed', 'think', =>

            if cost = Science.currentCost brain.player
                # log "tickBrain #{brain.player}", cost
                storage = world.storage[brain.player]
                if storage.canAfford cost
                    Science.deduct brain.player
                    storage.deduct cost
                    world.spent.costAtBot cost, brain
                    true

    # 000000000  00000000    0000000   0000000    00000000
    #    000     000   000  000   000  000   000  000
    #    000     0000000    000000000  000   000  0000000
    #    000     000   000  000   000  000   000  000
    #    000     000   000  000   000  0000000    00000000

    tickTrade: (delta, trade) ->

        return if trade.state != 'on'
        return if not trade.path

        @delay delta, trade, 'speed', 'trade', =>

            # log "trade.trade #{trade.player}"
            storage    = world.storage[trade.player]
            sellStone  = trade.sell
            sellAmount = science(trade.player).trade.sell
            # log "sell #{sellAmount} #{Stone.string sellStone}"
            if storage.has sellStone, sellAmount
                buyStone = trade.buy
                # log "buy #{Stone.string buyStone}"
                if storage.canTake buyStone
                    # log "trade #{trade.player} #{sellAmount} #{Stone.string sellStone} for 1 #{Stone.string buyStone}"
                    if world.tubes.insertPacket trade, buyStone
                        storage.willSend buyStone
                        storage.add sellStone, -sellAmount
                        cost = [0,0,0,0]
                        cost[sellStone] = sellAmount
                        world.spent.costAtBot cost, trade
            true

    # 0000000    000   000  000   000
    # 000   000  000   000   000 000
    # 0000000    000   000    00000
    # 000   000  000   000     000
    # 0000000     0000000      000

    buyButtonClick: (button) -> @buyBot button.bot

    buyBot: (type, player=0) ->

        storage = world.storage[player]
        cost = config.cost[Bot.string type]
        if not storage.canAfford cost
            if player == 0
                log "WARNING handle.buyBot #{Bot.string type} player:#{player} -- not enough stones for bot!", cost
                playSound 'fail', 'buyBot'
            return

        switch type 
            when Bot.mine, Bot.berta
                if world.botsOfType(type, player).length >= science(player)[Bot.string type].limit
                    # log "WARNING handle.buyBot player:#{player} -- #{Bot.string type} limit reached!"
                    playSound 'fail', 'buyBot' if player == 0
                    return
            else
                if world.botOfType(type, player)
                    log "WARNING handle.buyBot player:#{player} -- already has a #{Bot.string type}!"
                    playSound 'fail', 'buyBot' if player == 0
                    return
                    
        [p, face] = world.emptyPosFaceNearBot world.bases[player]
        if not p?
            # log "WARNING handle.buyBot player:#{player} -- no space for new bot!"
            playSound 'fail', 'buyBot' if player == 0
            return

        storage.deduct cost, 'buy'
        bot = world.addBot p.x,p.y,p.z, type, player, face
        world.spent.costAtBot cost, bot
        world.construct.botAtPos bot, p
        world.cages.updateCage bot
        
        switch type 
            when Bot.brain
                bot.state = 'on'
        
        if player == 0
            rts.camera.focusOnPos p
            world.highlightBot bot
            post.emit 'botCreated', bot
            
        bot

    #  0000000  00000000  000   000  0000000
    # 000       000       0000  000  000   000
    # 0000000   0000000   000 0 000  000   000
    #      000  000       000  0000  000   000
    # 0000000   00000000  000   000  0000000

    sendPacket: (bot) =>

        stone = world.stoneBelowBot bot
        storage = world.storage[bot.player]
        if storage.canTake stone
            if bot.path?
                if world.tubes.insertPacket bot, stone
                    if not world.isMeta
                        storage.willSend stone
                        if resource = world.resourceAtPos world.posBelowBot bot
                            resource.deduct()
                    return true
            else if bot.type == Bot.base
                storage?.add stone
                gained = [0,0,0,0]
                gained[stone] = 1
                world.spent.gainAtPosFace gained, bot.pos, bot.face
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
        
        if world.isStoneAtPos newPos
            newFace = (newFace+3) % 6
            n = Vector.normals[newFace]
            newPos = bot.pos.plus n

        if world.isItemAtPos newPos
            return
            
        pos:  newPos
        face: newFace
        norm: n
    
    canBuild: (norm, player=0) ->
        
        buildBot = world.botOfType Bot.build
        storage  = world.storage[player]
        
        return false if not buildBot
        return false if not storage.canAfford science(player).build.cost
        return false if Science.needsTube(buildBot.type, player) and not buildBot.path
        pos = buildBot.pos.plus norm
        return false if world.invalidPos pos
        return false if world.isItemAtPos pos
        return true
        
    buildBotHit: (bot, hit) ->

        
        player = 0
        
        if hitInfo = @infoForBuildHit bot, hit
            
            return if not @canBuild hitInfo.norm
            return if world.invalidPos hitInfo.pos

            storage = world.storage[player]
            if storage.deductBuild()

                rts.camera.focusOnPos rts.camera.center.plus hitInfo.norm

                world.addStone bot.pos.x, bot.pos.y, bot.pos.z
                world.spent.costAtBuild science(player).build.cost, bot
                @checkTargets world.indexAtPos hitInfo.pos
                world.moveBot bot, hitInfo.pos, hitInfo.face
                world.construct.stones()
                
                if @canBuild hitInfo.norm
                    world.showBuildGuide bot, hitInfo
            else
                world.removeBuildGuide()
                log 'not enough stones'
                
    build: (bot, norm) ->
        
        pos  = bot.pos.plus norm
        face = Vector.normalIndex norm
        
        storage = world.storage[bot.player]
        if storage.deductBuild()

            world.addStone bot.pos.x, bot.pos.y, bot.pos.z
            world.spent.costAtBuild science(bot.player).build.cost, bot            
            world.moveBot bot, pos, face
            world.construct.stones()
            
            if bot.player == 0
                rts.camera.focusOnPos rts.camera.center.plus norm
                if @canBuild norm
                    world.showBuildGuide bot, hitInfo
                    
            true
    
    doubleRightClick: ->
        
        hit = rts.castRay()
        if hit?.bot?.type == Bot.base
            @call()
        else
            @placeBuild()
    
    # 00     00   0000000   000   000  00000000        000   000  000  000000000  
    # 000   000  000   000  000   000  000             000   000  000     000     
    # 000000000  000   000   000 000   0000000         000000000  000     000     
    # 000 0 000  000   000     000     000             000   000  000     000     
    # 000   000   0000000       0      00000000        000   000  000     000     
    
    mouseMoveHit: (hit) ->
        
        world.removeBuildGuide()
        
        if hit and hit.bot? and hit.bot.player == 0
            world.highlightBot hit.bot
            if hit.bot.type == Bot.build
                if hitInfo = @infoForBuildHit hit.bot, hit
                    if @canBuild hitInfo.norm
                        world.showBuildGuide hit.bot, hitInfo
        else
            world.removeHighlight()
            
    placeBase: ->
        
        if hit = rts.castRay true
            if not hit.bot
                @moveBot world.bases[0], hit.pos, hit.face
                
    placeBuild: ->
        
        if build = world.botOfType Bot.build
            if hit = rts.castRay true
                if not hit.bot
                    @moveBot build, hit.pos, hit.face
            
    # 00     00   0000000   000   000  00000000
    # 000   000  000   000  000   000  000
    # 000000000  000   000   000 000   0000000
    # 000 0 000  000   000     000     000
    # 000   000   0000000       0      00000000

    moveBotToFaceIndex: (bot, faceIndex) ->
        
        [face, index] = world.splitFaceIndex faceIndex
        pos = world.posAtIndex index
        return @moveBot bot, pos, face
        
    moveBot: (bot, pos, face) ->

        return if bot.type == Bot.icon
        
        if not world.isItemAtPos(pos) or world.botAtPos(pos) == bot
            index = world.indexAtPos pos
            if bot.face != face or bot.index != index
                if world.canBotMoveTo bot, face, index
                    @checkTargets index if bot.player == 0
                    world.moveBot bot, pos, face
                    world.highlightBot bot
                    return true
                    
    # 000000000   0000000   00000000    0000000   00000000  000000000   0000000  
    #    000     000   000  000   000  000        000          000     000       
    #    000     000000000  0000000    000  0000  0000000      000     0000000   
    #    000     000   000  000   000  000   000  000          000          000  
    #    000     000   000  000   000   0000000   00000000     000     0000000   
    
    checkTargets: (index) ->

        if target = world.targets[index]
            world.targets[index].mesh.parent.remove world.targets[index].mesh
            delete world.targets[index]
            world.plosion.atPos world.posAtIndex(index), 0.5, Color.bot.cancer, 0.03
            if empty world.targets
                log 'all targets reached!'

    # 00     00   0000000   000   000   0000000  000000000  00000000  00000000   
    # 000   000  000   000  0000  000  000          000     000       000   000  
    # 000000000  000   000  000 0 000  0000000      000     0000000   0000000    
    # 000 0 000  000   000  000  0000       000     000     000       000   000  
    # 000   000   0000000   000   000  0000000      000     00000000  000   000  
    
    monsterMoved: (monster) ->

        for base in world.bases
            if base.state == 'on'
                if Math.round(monster.pos.manhattan(base.pos)) <= science(base.player).base.radius
                    Spark.spawn base, monster

    #  0000000   0000000   000      000      
    # 000       000   000  000      000      
    # 000       000000000  000      000      
    # 000       000   000  000      000      
    #  0000000  000   000  0000000  0000000  
    
    call: (player=0, cfg={moveWhenOnResource:true, moveBuild:true}) ->
        
        info = world.emptyResourceNearBase player
                
        botMoved = false
        baseIndex = world.faceIndexForBot world.bases[player]
        for type in [Bot.mine, Bot.brain, Bot.trade, Bot.berta, Bot.build]
            
            if type == Bot.build and not cfg.moveBuild
                break
                
            if not Science.needsTube type, player
                continue
            
            for bot in world.botsOfType type, player
                
                isOnResource = world.isResourceBelowBot bot
                
                if not cfg.moveWhenOnResource and isOnResource
                    log 'dont move on resource'
                    continue
                    
                if faceIndex = first(info.resource) ? first(info.empty)
                    botIndex = world.faceIndexForBot bot
                    # log "distanceFrom face #{world.stringForFaceIndex faceIndex} base #{world.stringForFaceIndex baseIndex} bot #{world.stringForFaceIndex botIndex}"
                    if ((not isOnResource) and valid(info.resource)) or world.distanceFromFaceToFace(faceIndex,baseIndex) < world.distanceFromFaceToFace(botIndex,baseIndex)
                        if valid info.resource then info.resource.shift()
                        else info.empty.shift()
                        moved = @moveBotToFaceIndex bot, faceIndex
                        # log "move:#{Bot.string bot.type}" if moved
                        botMoved = botMoved or moved
                    # else
                        # log "stay:#{Bot.string bot.type} #{world.distanceFromFaceToFace(faceIndex,baseIndex)} >= #{world.distanceFromFaceToFace(botIndex,baseIndex)}"
                else
                    # log 'no resource and no empty'
                    return botMoved
        botMoved
            
module.exports = Handle
