###
000   000   0000000   00000000   000      0000000  
000 0 000  000   000  000   000  000      000   000
000000000  000   000  0000000    000      000   000
000   000  000   000  000   000  000      000   000
00     00   0000000   000   000  0000000  0000000  
###

{ post, prefs, deg2rad, randInt, clamp, first, valid, empty, str, log, _ } = require 'kxk'

Vector    = require './lib/vector'
Packet    = require './packet'
Tubes     = require './tubes'
Boxes     = require './boxes'
Spent     = require './spent'
Graph     = require './graph'
Monster   = require './monster'
Storage   = require './storage'
Science   = require './science' 
Construct = require './construct'

{ Stone, Bot, Face, Edge, Bend } = require './constants'

class World
    
    constructor: (@scene, config) ->
        
        rts.world  = @
        
        @stones = {}
        @bots   = {}
        @monsters = []
        
        @tubes  = new Tubes @
        @spent  = new Spent @
        @boxes  = new Boxes @ 
        
        @setSpeed prefs.get 'speed', 6
        
        @sample = 0
        
        Science.initState config
                
        @build()
        
        @construct = new Construct @
        @construct.initBotGeoms()
        @construct.stones()
        @construct.bots()
        
        @updateTubes()
        
        if prefs.get 'graph', false
            Graph.toggle()
        
    setSpeed: (speedIndex) -> 
        @speedIndex = clamp 0, 12, speedIndex
        @speed = [1/8, 3/16, 1/4, 3/8, 1/2, 3/4, 1, 3/2, 2, 3, 4, 6, 8][@speedIndex]
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
        
        # log 'animate', scaledDelta
        
        @boxes.animate scaledDelta
        @spent.animate scaledDelta
        @tubes.animate scaledDelta
        
        for bot in @getBots()
            rts.handle.tickBot scaledDelta, bot
         
        if valid @monsters
            for i in [@monsters.length-1..0]
                @monsters[i].animate scaledDelta
            
        @storage.animate scaledDelta
        
        @sample -= scaledDelta
        if @sample <= 0
            Graph.sampleStorage @storage
            @sample = 1.0
        
        post.emit 'tick'
                 
    # 00     00   0000000   000   000   0000000  000000000  00000000  00000000   
    # 000   000  000   000  0000  000  000          000     000       000   000  
    # 000000000  000   000  000 0 000  0000000      000     0000000   0000000    
    # 000 0 000  000   000  000  0000       000     000     000       000   000  
    # 000   000   0000000   000   000  0000000      000     00000000  000   000  
    
    addMonster: (x,y,z,d) ->
        d ?= Vector.normals[randInt 6]
        monster = new Monster @, vec(x,y,z), d
        @monsters.push monster
        monster
        
    # 0000000     0000000   000000000  
    # 000   000  000   000     000     
    # 0000000    000   000     000     
    # 000   000  000   000     000     
    # 0000000     0000000      000     
    
    addBot: (x,y,z, type=Bot.mine, face=null) -> 
        
        p = @roundPos vec x,y,z
        
        if not face?
            [p,face] = @emptyPosFaceNearPos p
            if not p?
                log 'no empty space for bot!'
                return
        
        index = @indexAtPos p
        bot = 
            type:  type
            pos:   p
            face:  face
            index: index
            
        bot.mine = 1/Science.mineSpeed type
                
        switch type 
            when Bot.base
                @base = bot
                bot.prod = 1/state.science.base.speed
            when Bot.trade
                bot.trade = 1/state.science.trade.speed
            when Bot.brain
                bot.think = 1/state.science.brain.speed
            
        # log 'addBot', bot
        @bots[index] = bot
        bot

    getBots: -> Object.values @bots
    
    botsOfType: (type) -> @getBots().filter (b) -> b.type == type
    botOfType:  (type) -> first @botsOfType type
        
    # 00     00   0000000   000   000  00000000  
    # 000   000  000   000  000   000  000       
    # 000000000  000   000   000 000   0000000   
    # 000 0 000  000   000     000     000       
    # 000   000   0000000       0      00000000  
    
    moveBot: (bot, toPos, toFace=bot.face) ->
        
        # log 'moveBot', toPos
        
        fromIndex = bot.index
        toIndex = @indexAtPos toPos
        delete @bots[fromIndex]
        @bots[toIndex] = bot
        
        bot.face  = toFace
        bot.index = toIndex
        bot.delay = 1/bot.speed
        bot.pos = @roundPos toPos
        
        @updateTubes()
        @construct.updateBot bot
        
    updateTubes: ->
        
        @tubes.build()
        @construct.tubes()
            
    canBotMoveTo: (bot, face, index) -> @pathFromTo @faceIndex(bot.face, bot.index), @faceIndex(face, index)
    
    pathFromTo: (fromIndex, toFaceIndex) -> @tubes.astar.findPath fromIndex, toFaceIndex
    
    pathFromPosToPos: (from, to) -> @tubes.astar.posPath from, to
        
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
    addStone: (x,y,z, stone=Stone.gray) -> @stones[@indexAt x,y,z] = stone
        
    botAt:      (x,y,z) -> @bots[@indexAt x,y,z]
    botAtPos:   (v)     -> @bots[@indexAtPos v]
    stoneAtPos: (v)     -> @stones[@indexAtPos v]
        
    isStoneAt: (x,y,z) -> @stones[@indexAt x,y,z] != undefined
    isItemAt:  (x,y,z) -> @isStoneAt(x,y,z) or @botAt(x,y,z) 
    isItemAtPos: (p) -> @isItemAt p.x,p.y,p.z
                
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
        
        norm = new Vector n
        if n.equals Vector.unitX  then return 0
        if n.equals Vector.unitY  then return 1
        if n.equals Vector.unitZ  then return 2
        if n.equals Vector.minusX then return 3
        if n.equals Vector.minusY then return 4
        if n.equals Vector.minusZ then return 5
        
        v = new Vector v 
        dir = v.to @roundPos(v)
        angles = [0..5].map (i) -> index:i, norm:Vector.normals[i], angle:Vector.normals[i].angle(norm) + Vector.normals[i].angle(dir)
        angles.sort (a,b) -> a.angle - b.angle
        return angles[0].index
            
    faceIndex: (face,index) -> (face<<28) | index
    faceIndexForBot: (bot) -> @faceIndex bot.face, bot.index
    splitFaceIndex: (faceIndex) -> [faceIndex >> 28, faceIndex & ((Math.pow 2, 27)-1)]
        
    # 00000000  00     00  00000000   000000000  000   000  00000000    0000000    0000000  
    # 000       000   000  000   000     000      000 000   000   000  000   000  000       
    # 0000000   000000000  00000000      000       00000    00000000   000   000  0000000   
    # 000       000 0 000  000           000        000     000        000   000       000  
    # 00000000  000   000  000           000        000     000         0000000   0000000   
    
    emptyFaceIndex: (faceIndex) -> 
        
        [face,index] = @splitFaceIndex faceIndex
        @emptyIndex index
        
    emptyIndex: (index) ->
        not @bots[index] and not @stones[index]
    
    emptyPosFaceNearPos: (pos) ->
        
        pi = @indexAtPos pos
        
        check = [pi]
        known = new Set
        
        while valid check
            ci = check.shift()
            if @emptyIndex ci
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

        if @stoneAtPos(pos)?
            log 'stone above face!'
            return neighbors
        
        if not @stoneAtPos(pos.minus Vector.normals[face])?
            log "no stone below #{vec pos} face #{Face.string face}!"
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
        
        neighbors
        
    neighborsOfIndex: (index) => 
        
        pos = @posAtIndex index
        Vector.normals.map (dir) => @indexAtPos pos.plus dir
        
    emptyNeighborsOfIndex: (index) =>
        
        @neighborsOfIndex(index).filter (n) =>
            not @isItemAtPos @posAtIndex n
        
    # 000  000   000  0000000    00000000  000   000  
    # 000  0000  000  000   000  000        000 000   
    # 000  000 0 000  000   000  0000000     00000    
    # 000  000  0000  000   000  000        000 000   
    # 000  000   000  0000000    00000000  000   000  
    
    indexAt: (x,y,z) -> (x+256)+((y+256)<<9)+((z+256)<<18)
    indexAtPos: (v) -> p = @roundPos(v); @indexAt p.x, p.y, p.z
    
    # 00000000    0000000    0000000  
    # 000   000  000   000  000       
    # 00000000   000   000  0000000   
    # 000        000   000       000  
    # 000         0000000   0000000   
        
    posAtIndex: (index) -> 
        new Vector 
            x:( index      & 0b111111111)-256
            y:((index>>9 ) & 0b111111111)-256
            z:((index>>18) & 0b111111111)-256
            
    posAtFaceIndex: (faceIndex) -> 
        [face,index] = @splitFaceIndex faceIndex
        @posAtIndex index
    
    stoneBelowBot: (bot) -> @stoneAtPos @posBelowBot bot
    posBelowBot: (bot) -> bot.pos.minus Vector.normals[bot.face]            
    roundPos: (v) -> vec(v).round()
            
    # 000   000  000   0000000   000   000  000      000   0000000   000   000  000000000  
    # 000   000  000  000        000   000  000      000  000        000   000     000     
    # 000000000  000  000  0000  000000000  000      000  000  0000  000000000     000     
    # 000   000  000  000   000  000   000  000      000  000   000  000   000     000     
    # 000   000  000   0000000   000   000  0000000  000   0000000   000   000     000     
    
    removeHighlight: ->
        
        @highBot?.highlight?.parent.remove @highBot?.highlight
        if @baseCage
            @baseCage.parent.remove @baseCage
            delete @baseCage
        delete @highBot?.highlight
        delete @highBot
    
    highlightPos: (v) -> @highlightBot @botAtPos @roundPos v
        
    highlightBot: (bot) ->
        
        if bot
            if bot == @highBot
                @construct.orientFace bot.highlight, bot.face
                @baseCage?.position.copy bot.pos
                return
            @removeHighlight()
            @highBot = bot
            bot.highlight = @construct.highlight bot
            if bot.type == Bot.base
                @baseCage = @construct.cage bot, state.science.base.radius
        else
            @removeHighlight()
                                
    #  0000000  000000000  00000000   000  000   000   0000000   
    # 000          000     000   000  000  0000  000  000        
    # 0000000      000     0000000    000  000 0 000  000  0000  
    #      000     000     000   000  000  000  0000  000   000  
    # 0000000      000     000   000  000  000   000   0000000   
    
    stringForBot: (bot) -> Bot.string bot
            
    stringForFaceIndex: (faceIndex) ->
        
        [face,index] = @splitFaceIndex faceIndex
        pos = @posAtIndex index
        "#{pos.x} #{pos.y} #{pos.z} #{Face.string(face)}"
        
module.exports = World
