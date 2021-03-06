###
000   000   0000000   00000000   000      0000000  
000 0 000  000   000  000   000  000      000   000
000000000  000   000  0000000    000      000   000
000   000  000   000  000   000  000      000   000
00     00   0000000   000   000  0000000  0000000  
###

AI        = require './ai'
Packet    = require './packet'
Tubes     = require './tubes'
Cages     = require './cages'
Boxes     = require './boxes'
Spent     = require './spent'
Graph     = require './graph'
Bullet    = require './bullet'
Orbits    = require './orbits'
Cancer    = require './cancer'
Monster   = require './monster'
Storage   = require './storage'
Plosion   = require './plosion'
Resource  = require './resource'
Construct = require './construct'

class World
    
    constructor: (@scene) ->
                
        @stones    = {}
        @bots      = {}
        @resources = {}
        @targets   = {}
        @monsters  = []
        @cancers   = []
        @bases     = []
        @storage   = []
        @players   = []
        @ai        = []
        @idBot     = []
        
        @vec  = vec()
        @vec2 = vec()
        
        window.world   = @
        
        @cages         = new Cages @ 
        @tubes         = new Tubes @
        @spent         = new Spent @
        @plosion       = new Plosion @
        window.boxes   = new Boxes @scene, 20000
        @resourceBoxes = new Boxes @scene, 10000
        
        @boid    = 0
        @sample  = 0
        @timeSum = 0
        @cycles  = 0
                
        @build()
        
        @construct = new Construct
        @construct.init()
        
        @create()
        
        post.on 'storageChanged', @onStorageChanged
        
        @setSpeed       prefs.get 'speed', 6
        @setOpacity     prefs.get 'opacity', 6
        @setCageOpacity prefs.get 'cageOpacity', 6
          
    #  0000000  00000000   00000000   0000000   000000000  00000000  
    # 000       000   000  000       000   000     000     000       
    # 000       0000000    0000000   000000000     000     0000000   
    # 000       000   000  000       000   000     000     000       
    #  0000000  000   000  00000000  000   000     000     00000000  
    
    create: ->
        
        @construct.stones()
        @construct.bots()
        @construct.targets()
        @dirtyTubes()
        
        @setCageOpacity 3
        @setOpacity 7
        @setSpeed 6
        
        post.emit 'world', @
        
    #  0000000  000      00000000   0000000   00000000   
    # 000       000      000       000   000  000   000  
    # 000       000      0000000   000000000  0000000    
    # 000       000      000       000   000  000   000  
    #  0000000  0000000  00000000  000   000  000   000  
    
    clear: ->
        
        @tubes.clear()
        @spent.clear()
        Science.clear()
        Bullet.clear()
        Orbits.clear()
        
        @players = []
        @bases   = []
        @storage = []
        @ai      = []
        
        for index,stone of @stones
            delete @stones[index]
        @construct.stones()            
        
        for index,bot of @bots
            @delBot bot
        
        for index,resource of @resources
            resource.del()
        @resources = {}
        
        while @monsters.length
            @monsters[0].del()

        for cancer in @cancers
            cancer.del()
        @cancers = []

        for index,target of @targets
            target.mesh.parent.remove target.mesh
        @targets = {}
        
        boxes.clear()
        @botid = 0
                
    drawBrokenPath: (info) ->
        
        # log info
        g = new THREE.Geometry
        for open in info.open
            p = @posAtIndex open
            g.merge Geometry.box 0.1, p.x, p.y, p.z
            
        @scene.add new THREE.Mesh g, Materials.cancer
        
        p = @posAtIndex info.start
        g = Geometry.coordinateCross 0.05, p.x, p.y, p.z
        @scene.add new THREE.Mesh g, Materials.stone[0]

        p = @posAtIndex info.goal
        g = Geometry.coordinateCross 0.05, p.x, p.y, p.z
        @scene.add new THREE.Mesh g, Materials.stone[1]
        
    #  0000000   0000000   00     00  00000000  00000000    0000000   
    # 000       000   000  000   000  000       000   000  000   000  
    # 000       000000000  000000000  0000000   0000000    000000000  
    # 000       000   000  000 0 000  000       000   000  000   000  
    #  0000000  000   000  000   000  00000000  000   000  000   000  
    
    setCamera: (cfg={dist:10, rotate:45, degree:45}) ->
        
        rts.camera.dist   = cfg.dist   ? 10
        rts.camera.rotate = cfg.rotate ? 45
        rts.camera.degree = cfg.degree ? 45
        if cfg.pos?
            rts.camera.focusOnPos vec cfg.pos
        else
            rts.camera.focusOnPos @bases[0].pos
        rts.camera.update()
        
    #  0000000   00000000    0000000    0000000  000  000000000  000   000  
    # 000   000  000   000  000   000  000       000     000      000 000   
    # 000   000  00000000   000000000  000       000     000       00000    
    # 000   000  000        000   000  000       000     000        000     
    #  0000000   000        000   000   0000000  000     000        000     
    
    setOpacity: (opacityIndex) ->
        
        @opacityIndex = clamp 0, config.world.opacity.length-1, opacityIndex
        @opacity = config.world.opacity[@opacityIndex]

        prefs.set 'opacity', @opacityIndex
        
        for stone in Stone.all
            @construct.stoneMeshes[stone].material.transparent = true
            @construct.stoneMeshes[stone].material.opacity = @opacity
        
        @resourceBoxes.cluster.material.transparent = true
        @resourceBoxes.cluster.material.opacity = @opacity
        post.emit 'worldOpacity', @opacity, @opacityIndex
        
    resetOpacity: -> @setOpacity 6
    incrOpacity:  -> @setOpacity @opacityIndex + 1
    decrOpacity:  -> @setOpacity @opacityIndex - 1
        
    setCageOpacity: (cageOpacityIndex) ->
        
        @cageOpacityIndex = clamp 0, config.world.cageOpacity.length-1, cageOpacityIndex
        @cageOpacity = config.world.cageOpacity[@cageOpacityIndex]

        prefs.set 'cageOpacity', @cageOpacityIndex
        post.emit 'cageOpacity', @cageOpacity, @cageOpacityIndex
        
    resetCageOpacity: -> @setCageOpacity 6
    incrCageOpacity:  -> @setCageOpacity @cageOpacityIndex + 1
    decrCageOpacity:  -> @setCageOpacity @cageOpacityIndex - 1
    
    #  0000000  00000000   00000000  00000000  0000000    
    # 000       000   000  000       000       000   000  
    # 0000000   00000000   0000000   0000000   000   000  
    #      000  000        000       000       000   000  
    # 0000000   000        00000000  00000000  0000000    
    
    setSpeed: (speedIndex) -> 
        
        @speedIndex = clamp 0, config.world.speed.length-1, speedIndex
        @speed = config.world.speed[@speedIndex]
        # log "speed #{@speedIndex} #{@speed}"
        prefs.set 'speed',      @speedIndex
        post.emit 'worldSpeed', @speed, @speedIndex

    resetSpeed: -> @setSpeed 6
    incrSpeed:  -> @setSpeed @speedIndex + 1
    decrSpeed:  -> @setSpeed @speedIndex - 1
        
    #  0000000   000   000  000  00     00   0000000   000000000  00000000  
    # 000   000  0000  000  000  000   000  000   000     000     000       
    # 000000000  000 0 000  000  000000000  000000000     000     0000000   
    # 000   000  000  0000  000  000 0 000  000   000     000     000       
    # 000   000  000   000  000  000   000  000   000     000     00000000  
    
    animate: (delta) ->
        
        scaledDelta = delta * @speed
        @simulate scaledDelta
        boxes.render()
        @resourceBoxes.render()
        @cages.animate scaledDelta
        @plosion.animate scaledDelta
        Bullet.animate scaledDelta
        Orbits.animate scaledDelta
        post.emit 'tick'
        
    dirtyTubes: -> @tubes.dirty = true        
    updateTubes: ->
        
        if @tubes.dirty
            @tubes.build()
            @tubes.dirty = false
        
    simulate: (scaledDelta) ->
        
        @timeSum += scaledDelta
        
        @cycles = Math.floor @timeSum/60
        
        @spent.animate scaledDelta
        @tubes.animate scaledDelta
        
        for bot in @allBots()
            handle.tickBot scaledDelta, bot
         
        if valid @monsters
            for i in [@monsters.length-1..0]
                @monsters[i].animate scaledDelta
                
        if valid @cancers
            for i in [@cancers.length-1..0]
                @cancers[i].animate scaledDelta
                
        if valid @ai
            for ai in @ai
                ai.animate scaledDelta
                    
        @sample -= scaledDelta
        if @sample <= 0
            Graph.sampleStorage @storage[0] if @storage.length
            @sample = 1.0
                    
    # 00000000   00000000   0000000   0000000   000   000  00000000    0000000  00000000  
    # 000   000  000       000       000   000  000   000  000   000  000       000       
    # 0000000    0000000   0000000   000   000  000   000  0000000    000       0000000   
    # 000   000  000            000  000   000  000   000  000   000  000       000       
    # 000   000  00000000  0000000    0000000    0000000   000   000   0000000  00000000  
    
    resourceAt: (index) -> @resources[index]
    resourceAtPos: (pos) -> @resourceAt @indexAtPos pos
    isResourceAtIndex: (i) -> @resourceAt i
    isResourceAtPos:   (p) -> @resourceAt @indexAtPos p
    
    stoneOrResourceAtPos: (pos) ->
        stone = @stoneAtPos pos
        if stone not in Stone.resources
            index = @indexAtPos pos
            if @resources[index]
                return @resources[index].stone
        stone
        
    stoneBelowBot: (bot) -> @stoneOrResourceAtPos @posBelowBot bot
    resourceBelowBot: (bot) -> 
        
        stone = @stoneBelowBot bot
        if stone in Stone.resources
            return stone
        null
        
    noResourceBelowBot: (bot) -> not @isResourceBelowBot bot
    isResourceBelowBot: (bot) -> null != @resourceBelowBot bot
        
    stoneAtFaceIndex: (faceIndex) ->
        
        [face,index] = @splitFaceIndex faceIndex
        @stoneOrResourceAtPos @posAtIndex(index).minus Vector.normals[face]
    
    addResource: (x, y, z, stone, amount=1) ->
        
        index = @indexAt x,y,z
        if not @resourceAt index
            @resources[index] = new Resource index, stone, amount
        
    emptyResources: (cfg) ->
        
        positions = []
        for index,resource of @resources
            positions.push @posAtIndex index
        for index,stone of @stones
            positions.push @posAtIndex index if stone in Stone.resources
        
        found = []
        
        for pos in positions
            for n in [0...6]
                if not @isItemAtPos pos.plus Vector.normals[n]
                    found.push @faceIndex n, @indexAtPos pos.plus Vector.normals[n]
        
        if cfg?.sortPos
            found.sort (a,b) => @posAtIndex(a).manhattan(cfg.sortPos)-@posAtIndex(b).manhattan(cfg.sortPos)
        found
            
    facesReachableFromFaceIndex: (faceIndex) ->
        
        maxDist = 1000
        check = [faceIndex]
        known = {}
        known[faceIndex] = 
            dist:0
            faceIndex:faceIndex

        while valid check
            ci = check.shift()
            known[ci] ?= faceIndex:ci

            dist = known[ci].dist
            for neighbor in @neighborsOfFaceIndex ci
                if not known[neighbor]
                    minDist = dist+1
                    for nn in @neighborsOfFaceIndex neighbor
                        if known[nn]? and known[nn].dist+1 < minDist
                            minDist = known[nn].dist+1
                    if minDist <= maxDist and @emptyFaceIndex(neighbor) # limit path length
                        known[neighbor] ?= faceIndex:neighbor
                        known[neighbor].dist = minDist
                        check.push neighbor
                
        faces = Object.values(known)
        faces = faces.map (k) -> k.faceIndex
        faces
        
    faceIndexClosestToFaceIndexReachableFromFaceIndex: (targetFaceIndex, sourceFaceIndex) ->
        
        targetPos = @posAtIndex targetFaceIndex
        @faceIndexClosestToPosReachableFromFaceIndex targetPos, sourceFaceIndex

    faceIndexClosestToPosReachableFromFaceIndex: (targetPos, sourceFaceIndex) ->
        
        faces = @facesReachableFromFaceIndex sourceFaceIndex
        if valid faces
            faces.sort (a,b) => @posAtIndex(a).manhattan(targetPos)-@posAtIndex(b).manhattan(targetPos)
            first faces
            
    # 00     00   0000000   000   000   0000000  000000000  00000000  00000000   
    # 000   000  000   000  0000  000  000          000     000       000   000  
    # 000000000  000   000  000 0 000  0000000      000     0000000   0000000    
    # 000 0 000  000   000  000  0000       000     000     000       000   000  
    # 000   000   0000000   000   000  0000000      000     00000000  000   000  
    
    scatterMonsters: (x,y,z,r,n) ->
        
        for i in [0...n]
            f = Math.random() * r
            p = @roundPos vec(x,y,z).plus Vector.random().mul f
            @addMonster p.x, p.y, p.z
    
    addMonster: (x,y,z) ->
        
        monster = new Monster vec(x,y,z), Vector.normals[randInt 6]
        @monsters.push monster
        monster
        
    monsterClosestToPos: (pos) ->
        
        minDist = Number.MAX_VALUE
        for monster in @monsters
            if monster.pos.manhattan(pos) < minDist
                minDist = monster.pos.manhattan(pos)
                minMonster = monster
        minMonster
        
    enemyClosestToBot: (bot) ->
        
        minDist = Number.MAX_VALUE
        for enemy in @enemiesOfBot bot
            if enemy.pos.manhattan(bot.pos) < minDist
                minDist = enemy.pos.manhattan(bot.pos)
                minEnemy = enemy
        minEnemy
        
    addCancer: (x,y,z) ->
        
        @cancers.push new Cancer vec(x,y,z)
        last @cancers
        
    addAI: (bot) ->
        
        @ai.push new AI bot
                
    # 0000000     0000000   000000000  
    # 000   000  000   000     000     
    # 0000000    000   000     000     
    # 000   000  000   000     000     
    # 0000000     0000000      000     
    
    addBot: (x,y,z, type=Bot.mine, player=0, face=null) -> 
        
        @dirtyTubes()
        
        p = @roundPos vec x,y,z

        if not face?
            [p,face] = @emptyPosFaceNearPos p
            if not p?
                log 'no empty space for bot!'
                return
        
        if player == 0 and type == Bot.base and @bases.length
            player = @bases.length
                
        index = @indexAtPos p
        bot = 
            type:   type
            pos:    p
            face:   face
            index:  index
            player: player
            id:     @botid
            
        @botid += 1
            
        bot.posBelow = p.minus Vector.normals[face]
        bot.mine = 1/Science.mineSpeed bot
        
        if type != Bot.icon
            bot.hitPoints = bot.health = bot.maxHealth = config[Bot.string type].health
                
        if type in Bot.switchable
            bot.state = 'off'
        
        switch type 
            when Bot.base
                Science.addPlayer()
                @storage.push new Storage player
                @players.push player
                if player
                    @addAI bot
                @bases[player] = bot
                bot.prod = 1/science(player).base.speed
            when Bot.trade
                bot.trade = 1/science(player).trade.speed
                bot.sell  = Stone.red
                bot.buy   = Stone.blue
            when Bot.brain
                bot.think = 1/science(player).brain.speed
            when Bot.berta
                bot.shoot = 1/science(player).berta.speed
                if @botOfType(Bot.berta,player)?.state == 'on'
                    bot.state = 'on'
                    
        @bots[index] = bot
        @idBot[bot.id] = bot
        bot

    # 000   0000000   0000000   000   000  
    # 000  000       000   000  0000  000  
    # 000  000       000   000  000 0 000  
    # 000  000       000   000  000  0000  
    # 000   0000000   0000000   000   000  
    
    addIcon: (x,y,z, func) ->

        iconBot = @addBot x,y,z, Bot.icon
        if not func
            Science.addPlayer()
            @bases[0] = iconBot
        else
            iconBot.func = func
        iconBot
        
    # 000000000   0000000   00000000    0000000   00000000  000000000  
    #    000     000   000  000   000  000        000          000     
    #    000     000000000  0000000    000  0000  0000000      000     
    #    000     000   000  000   000  000   000  000          000     
    #    000     000   000  000   000   0000000   00000000     000     
    
    addTarget: (x,y,z) ->
        
        @targets[@indexAt x,y,z] = {}
        
    #  0000000   0000000   000       0000000   00000000   
    # 000       000   000  000      000   000  000   000  
    # 000       000   000  000      000   000  0000000    
    # 000       000   000  000      000   000  000   000  
    #  0000000   0000000   0000000   0000000   000   000  
    
    colorBot: (bot) ->

        return if not bot.mesh
        if bot.player == 0
            stone = @resourceBelowBot bot
            if stone? and (bot.path? or bot.type == Bot.base)
                bot.mesh.material = Materials.bot[stone]
            else if @isMeta
                bot.mesh.material = Materials.ai[0]
            else 
                bot.mesh.material = Materials.bot[Stone.gray]
        else
            bot.mesh.material = Materials.ai[bot.player-1]
        
    baseForBot: (bot) -> @bases[bot.player]
        
    allBots: -> Object.values @bots
    botsOfPlayer: (player=0) -> @allBots().filter (bot) -> bot.player == player
    enemiesOfBot: (bot) -> @allBots().filter (e) -> e.player != bot.player #and e.type in [Bot.base, Bot.berta]
    
    botsOfType: (type, player=0) -> @botsOfPlayer(player).filter (b) -> b.type == type
    botOfType:  (type, player=0) -> first @botsOfType type, player
        
    removePlayer: (player) ->
        
        for bot in @botsOfPlayer player 
            @removeBot bot
            
        for ai in @ai
            if ai.player == player
                @ai.splice @ai.indexOf(ai), 1
                break
            
    removeBot: (bot) ->
        
        post.emit 'botWillBeRemoved', bot
        Orbits.removeBot bot
        Bullet.removeBot bot
        @plosion.atBot bot
        @delBot bot
        @dirtyTubes()
        post.emit 'botRemoved', bot.type, bot.player
        
    delBot: (bot) ->
        
        @cages.removeCage bot
        index = @indexAtBot bot
        bot.highlight?.parent.remove bot.highlight
        bot.mesh?.parent.remove bot.mesh
        bot.dot?.parent.remove bot.dot
        delete bot.highlight
        delete bot.mesh
        delete bot.dot
        delete @bots[index]
    
    # 00     00   0000000   000   000  00000000  
    # 000   000  000   000  000   000  000       
    # 000000000  000   000   000 000   0000000   
    # 000 0 000  000   000     000     000       
    # 000   000   0000000       0      00000000  
    
    moveBot: (bot, toPos, toFace=bot.face) ->
        
        fromIndex = bot.index
        toIndex = @indexAtPos toPos
        delete @bots[fromIndex]
        @bots[toIndex] = bot
        
        bot.face  = toFace
        bot.index = toIndex
        bot.delay = 1/bot.speed
        bot.pos.copy toPos
        bot.pos.round()
        bot.posBelow.copy bot.pos
        bot.posBelow.sub Vector.normals[bot.face]
        
        @removeBuildGuide()
        @dirtyTubes()
        @construct.updateBot bot
        @cages.moveBot bot
                    
    canBotMoveTo: (bot, face, index) -> 
        
        return false if @isItemAtIndex(index) and @botAtIndex(index) != bot
        @pathFromFaceToFace @faceIndexForBot(bot), @faceIndex(face, index)
    
    pathFromFaceToFace: (fromFaceIndex, toFaceIndex) -> @tubes.astar.findPath fromFaceIndex, toFaceIndex
    
    pathFromPosToPos: (from, to) -> 
    
        if @noItemAtPos(to) 
            return @tubes.astar.posPath from, to
        # else
            # log "pathFromPosToPos item! stone:#{Stone.string @stoneAtPos to} bot:#{Bot.string @botAtPos(to)?.type}", to
        null
    
    bulletPath: (fromBot, toBot) -> @tubes.astar.bulletPath fromBot, toBot
        
    distanceFromFaceToFace: (fromFaceIndex, toFaceIndex) ->
        
        # log "distanceFromFaceToFace #{@stringForFaceIndex fromFaceIndex} #{@stringForFaceIndex toFaceIndex}"
        
        @pathFromFaceToFace(fromFaceIndex, toFaceIndex)?.length ? Number.MAX_VALUE
        
    # 0000000    000   000  000  000      0000000    
    # 000   000  000   000  000  000      000   000  
    # 0000000    000   000  000  000      000   000  
    # 000   000  000   000  000  000      000   000  
    # 0000000     0000000   000  0000000  0000000    
    
    build: ->
                        
    wall: (xs, ys, zs, xe, ye, ze, stone=Stone.gray) ->
        
        for x in [xs..xe]
            for y in [ys..ye]
                for z in [zs..ze]
                    @addStone x, y, z, stone
                    
    delStone: (x,y,z) -> delete @stones[@indexAt x,y,z]
    addStone: (x,y,z, stone=Stone.gray, resource=0) -> 
    
        return if x <= -128
        return if y <= -128
        return if z <= -128
        return if x >=  128
        return if y >=  128
        return if z >=  128
        
        index = @indexAt x,y,z
        @stones[index] = stone
        
        if resource and stone != Stone.gray
            @addResource x, y, z, stone, resource
            @stones[index] = Stone.gray
       
    botWithId: (id) -> @idBot[id]
    botAt:    (x,y,z) -> @botAtIndex @indexAt x,y,z
    botAtPos:     (v) -> @botAtIndex @indexAtPos v
    botAtIndex:   (i) -> @bots[i]
    isBotAtPos:   (p) -> @botAtPos p
    isBotAtIndex: (i) -> @botAtIndex i

    stoneAtPos:   (v) -> @stoneAtIndex @indexAtPos v
    stoneAtIndex: (i) -> @stones[i]
        
    isStoneAt: (x,y,z)  -> @isStoneAtIndex @indexAt x,y,z
    isStoneAtPos:   (p) -> @isStoneAtIndex @indexAtPos p 
    isStoneAtIndex: (i) -> @stoneAtIndex(i)?
    
    isItemAt:  (x,y,z) -> @isItemAtIndex @indexAt x,y,z
    isItemAtPos:   (p) -> @isItemAtIndex @indexAtPos p
    isItemAtIndex: (i) -> @isStoneAtIndex(i) or @botAtIndex(i) or Cancer.isCellAtIndex i
    
    noBotAtPos:    (p) -> not @isBotAtPos p
    noStoneAtPos:  (p) -> not @isStoneAtPos p
    noItemAtPos:   (p) -> not @isItemAtPos p
    noItemAtIndex: (i) -> not @isItemAtIndex i
    noBotAtIndex:  (i) -> not @isBotAtIndex i
                
    noStoneAroundPosInDirection: (pos, dir) ->
        @vec.copy pos
        @vec.add dir
        return false if @isStoneAtPos @vec
        for n in Vector.perpNormals dir
            @vec.copy pos
            @vec.add n
            return false if @isStoneAtPos @vec
            @vec.add dir
            return false if @isStoneAtPos @vec
            @vec2.copy dir
            @vec2.cross n
            @vec.add @vec2
            return false if @isStoneAtPos @vec
        true
    
    # 00000000   0000000    0000000  00000000  
    # 000       000   000  000       000       
    # 000000    000000000  000       0000000   
    # 000       000   000  000       000       
    # 000       000   000   0000000  00000000  
    
    directionFaceToFace: (fromFaceIndex, toFaceIndex) ->
        
        [toFace, toIndex] = @splitFaceIndex toFaceIndex
        
        switch @bendType fromFaceIndex, toFaceIndex
            when Bend.flat  # vector to target
                [fromFace, fromIndex] = @splitFaceIndex fromFaceIndex
                @posAtIndex(fromIndex).to(@posAtIndex toIndex).mul 0.5
            when Bend.concave # flip target face normal
                Vector.normals[(toFace+3)%6].mul 0.3
            when Bend.convex # target face normal
                Vector.normals[toFace].mul 0.475 
    
    bendType: (fromFaceIndex, toFaceIndex) ->
        
        [fromFace, fromIndex] = @splitFaceIndex fromFaceIndex
        [  toFace,   toIndex] = @splitFaceIndex toFaceIndex
        
        return Bend.flat    if fromFace  == toFace
        return Bend.concave if fromIndex == toIndex
        Bend.convex
                
    faceAtPosNorm: (v,n) -> 
        
        if Vector.unitX.equals n  then return 0
        if Vector.unitY.equals n  then return 1
        if Vector.unitZ.equals n  then return 2
        if Vector.minusX.equals n then return 3
        if Vector.minusY.equals n then return 4
        if Vector.minusZ.equals n then return 5
        
        v = vec v 
        dir = v.to @roundPos(v)
        angles = [0..5].map (i) -> index:i, norm:Vector.normals[i], angle:Vector.normals[i].angle(n) + Vector.normals[i].angle(dir)
        angles.sort (a,b) -> a.angle - b.angle
        return angles[0].index
            
    faceIndex: (face,index) -> (face<<25) | index
    faceIndexForBot: (bot) -> @faceIndex bot.face, bot.index
    splitFaceIndex: (faceIndex) -> [faceIndex >> 25, faceIndex & 16777215] # 2^24-1
        
    # 00000000  00     00  00000000   000000000  000   000  00000000    0000000    0000000  
    # 000       000   000  000   000     000      000 000   000   000  000   000  000       
    # 0000000   000000000  00000000      000       00000    00000000   000   000  0000000   
    # 000       000 0 000  000           000        000     000        000   000       000  
    # 00000000  000   000  000           000        000     000         0000000   0000000   
    
    emptyFaceIndex: (faceIndex) -> 
        
        [face,index] = @splitFaceIndex faceIndex
        @noItemAtIndex index
        
    emptyPosFaceNearPos: (pos) ->
        
        pi = @indexAtPos pos
        
        check = [pi]
        known = new Set
        
        while valid check
            ci = check.shift()
            if @noItemAtIndex ci
                pos = @posAtIndex ci
                for face in [Face.PZ, Face.PX, Face.PY, Face.NX, Face.NY, Face.NZ]
                    if @stoneAtPos pos.minus Vector.normals[face]
                        return [pos,face]
            else
                known.add ci
                for neighbor in @neighborsOfIndex ci
                    if not known.has neighbor
                        check.push neighbor
        [null,null]
        
    emptyResourceNearBase: (player=0) -> @emptyResourceNearBot @bases[player], science(player).path.length
        
    emptyResourceNearBot: (bot, maxDist=1000) ->
                
        fi = @faceIndexForBot bot
        
        check = [fi]
        known = {}
        known[fi] = 
            dist:0
            faceIndex:fi
            empty:false

        while valid check
            ci = check.shift()
            known[ci] ?= faceIndex:ci
            if @emptyFaceIndex(ci) and ci != fi
                known[ci].empty = true
                if @stoneAtFaceIndex(ci) in Stone.resources
                    known[ci].resource = @stoneAtFaceIndex(ci)

            dist = known[ci].dist
            for neighbor in @neighborsOfFaceIndex ci
                if not known[neighbor]
                    minDist = dist+1
                    for nn in @neighborsOfFaceIndex neighbor
                        if known[nn]? and known[nn].dist+1 < minDist
                            log 'found shorter'
                            minDist = known[nn].dist+1
                    if minDist <= maxDist # limit path length
                        known[neighbor] ?= faceIndex:neighbor
                        known[neighbor].dist = minDist
                        check.push neighbor
                
        faces = Object.values known
        faces.sort (a,b) -> a.dist-b.dist

        empties = faces.filter (f) -> f.empty and not f.resource?
        ressies = faces.filter (f) -> f.empty and f.resource?
                 
        empty:   empties.map (f) -> f.faceIndex
        resource:ressies.map (f) -> f.faceIndex
              
    emptyPosFaceNearBot: (bot) ->
        
        fi = @faceIndexForBot bot
        
        check = [fi]
        known = new Set
        
        while valid check
            ci = check.shift()
            if @emptyFaceIndex ci
                [face,index] = @splitFaceIndex ci
                pos = @posAtIndex index
                return [pos,face]
            else
                known.add ci
                for neighbor in @neighborsOfFaceIndex ci
                    if not known.has neighbor
                        check.push neighbor
        [null,null]
    
    # 000   000  00000000  000   0000000   000   000  0000000     0000000   00000000    0000000  
    # 0000  000  000       000  000        000   000  000   000  000   000  000   000  000       
    # 000 0 000  0000000   000  000  0000  000000000  0000000    000   000  0000000    0000000   
    # 000  0000  000       000  000   000  000   000  000   000  000   000  000   000       000  
    # 000   000  00000000  000   0000000   000   000  0000000     0000000   000   000  0000000   
    
    dirsForFace: (face) ->
        
        [[Vector.PY, Vector.PZ, Vector.NY, Vector.NZ]
         [Vector.PZ, Vector.PX, Vector.NZ, Vector.NX]
         [Vector.PX, Vector.PY, Vector.NX, Vector.NY]
        ][face%3]
    
    neighborsOfFaceIndex: (faceIndex) => 
        
        [face, index] = @splitFaceIndex faceIndex
        pos = @posAtIndex index
        
        neighbors = []

        if @isStoneAtPos pos
            log "stone at face #{@stringForFaceIndex faceIndex} #{Stone.string @stoneAtPos pos}!"
            return neighbors
        
        if @noStoneAtPos pos.minus Vector.normals[face]
            log "no stone below #{@stringForFaceIndex faceIndex}!"
            return neighbors
            
        for dir in @dirsForFace face

            unit = Vector.normals[dir]
            fpos = pos.plus unit
            dpos = fpos.minus Vector.normals[face]
            if @stoneAtPos(fpos)?
                neighbors.push @faceIndex (dir+3)%6, index
            else if @stoneAtPos(dpos)?
                neighbors.push @faceIndex face, @indexAtPos fpos
            else
                neighbors.push @faceIndex dir, @indexAtPos dpos
        
        # log "neighbors of #{@stringForFaceIndex faceIndex}"
        # for neighbor in neighbors
            # log "         #{@stringForFaceIndex neighbor}"
        neighbors
        
    neighborsOfIndex: (index) => 
        
        pos = @posAtIndex index
        Vector.normals.map (dir) => @indexAtPos pos.plus dir
        
    emptyNeighborsOfIndex: (index) =>
        
        @neighborsOfIndex(index).filter (n) => @noItemAtPos @posAtIndex n

    emptyOrBotNeighborsOfIndex: (index) =>
        
        @neighborsOfIndex(index).filter (n) => 
            p = @posAtIndex n
            @isBotAtPos(p) or @noItemAtPos(p)
        
    # 000  000   000  0000000    00000000  000   000  
    # 000  0000  000  000   000  000        000 000   
    # 000  000 0 000  000   000  0000000     00000    
    # 000  000  0000  000   000  000        000 000   
    # 000  000   000  0000000    00000000  000   000  
    
    indexAt: (x,y,z) -> (Math.round(x)+128)+((Math.round(y)+128)<<8)+((Math.round(z)+128)<<16)
    indexAtPos: (v) -> @indexAt v.x, v.y, v.z
    indexAtBot: (bot) -> @indexAtPos bot.pos
    
    # 00000000    0000000    0000000  
    # 000   000  000   000  000       
    # 00000000   000   000  0000000   
    # 000        000   000       000  
    # 000         0000000   0000000   
        
    indexToPos: (index,pos) -> 
        pos.x = ( index      & 0b11111111)-128
        pos.y = ((index>>8 ) & 0b11111111)-128
        pos.z = ((index>>16) & 0b11111111)-128
        pos
        
    invalidPos: (pos) -> not @validPos pos
    validPos: (pos) -> 

        return false if pos.x > 127 or pos.x < -127
        return false if pos.y > 127 or pos.y < -127
        return false if pos.z > 127 or pos.z < -127
        return true
        
    posAtIndex: (index) -> @indexToPos index, vec()
            
    posAtFaceIndex: (faceIndex) -> 
        [face,index] = @splitFaceIndex faceIndex
        @posAtIndex index
    
    roundPos: (v) -> v.rounded()
    posBelowBot: (bot) -> bot.posBelow
                
    # 000   000  000   0000000   000   000  000      000   0000000   000   000  000000000  
    # 000   000  000  000        000   000  000      000  000        000   000     000     
    # 000000000  000  000  0000  000000000  000      000  000  0000  000000000     000     
    # 000   000  000  000   000  000   000  000      000  000   000  000   000     000     
    # 000   000  000   0000000   000   000  0000000  000   0000000   000   000     000     
    
    removeHighlight: ->
        
        @highBot?.highlight?.parent.remove @highBot?.highlight
        delete @highBot?.highlight
        delete @highBot
        @removeBuildGuide()
    
    highlightPos: (v) -> @highlightBot @botAtPos @roundPos v
        
    highlightBot: (bot) ->
        
        return if bot.player != 0
        if bot
            if bot == @highBot 
                @construct.orientFace bot.highlight, bot.face
                return
            @removeHighlight()
            @highBot = bot
            bot.highlight = @construct.highlight bot
        else
            @removeHighlight()
            
    # 0000000    000   000  000  000      0000000    
    # 000   000  000   000  000  000      000   000  
    # 0000000    000   000  000  000      000   000  
    # 000   000  000   000  000  000      000   000  
    # 0000000     0000000   000  0000000  0000000    
    
    onStorageChanged: (storage, stone, amount) =>

        return if storage.player != 0
        
        if @highBot?.type == Bot.build and not @buildGuide
            hit = rts.castRay false
            if hit?.bot?
                if hitInfo = handle.infoForBuildHit @highBot, hit
                    if handle.canBuild hitInfo.norm
                        @showBuildGuide @highBot, hitInfo
            
    removeBuildGuide: ->
  
        @buildGuide?.parent.remove @buildGuide
        delete @buildGuide
        
    showBuildGuide: (bot, hitInfo) ->
        
        stone = @stoneBelowBot bot
        if stone in Stone.resources
            mat = Materials.bot[stone]
        else
            mat = Materials.bot[Stone.gray]
        
        geom = Geometry.cornerBoxGeom 0.3
        @buildGuide = new THREE.Mesh geom, mat
        @scene.add @buildGuide
            
        @buildGuide.bot = Bot.build
        @buildGuide.position.copy bot.pos.plus hitInfo.norm.mul 0.3
        @buildGuide.quaternion.copy Quaternion.unitVectors Vector.unitZ, hitInfo.norm
                                
    #  0000000  000000000  00000000   000  000   000   0000000   
    # 000          000     000   000  000  0000  000  000        
    # 0000000      000     0000000    000  000 0 000  000  0000  
    #      000     000     000   000  000  000  0000  000   000  
    # 0000000      000     000   000  000  000   000   0000000   
    
    stringForBot: (bot) -> Bot.string bot
            
    stringForIndex: (index) -> pos = @posAtIndex index; "#{pos.x} #{pos.y} #{pos.z}"
    stringForFaceIndex: (faceIndex) ->
        [face,index] = @splitFaceIndex faceIndex
        pos = @posAtIndex index
        # log "stringForFaceIndex #{faceIndex}", "#{pos.x} #{pos.y} #{pos.z} #{Face.string(face)}"
        "#{pos.x} #{pos.y} #{pos.z} #{Face.string(face)}"
        
module.exports = World
