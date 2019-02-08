###
000   000   0000000   00000000   000      0000000  
000 0 000  000   000  000   000  000      000   000
000000000  000   000  0000000    000      000   000
000   000  000   000  000   000  000      000   000
00     00   0000000   000   000  0000000  0000000  
###

{ deg2rad, log, _ } = require 'kxk'

THREE     = require 'three'
AStar     = require './lib/astar'
Vector    = require './lib/vector'
Materials = require './materials'
Construct = require './construct'

{ Stone, Bot, Face } = require './constants'

class World
    
    constructor: (@scene) ->
        
        @stones = {}
        @bots = {}
        
        @astar = new AStar @
        
        @build()
                        
        @construct = new Construct @
        @construct.initBotGeoms()
        @construct.baseDot()
        @construct.stones()
        @construct.bots()
        @construct.paths()
        
    build: ->
        
        # # for z in [-5..0]
        # for z in [0..0]
            # for y in [-10..10]
                # @wall -40,y*4,z*2, 40,y*4,z*2
                # @wall y*4,-40,z*2, y*4,40,z*2
  
        # @wall -128, 0, 0, 128, 0, 0
        # @wall 0, -128, 0, 0, 128, 0
        
        
        @wall -2, 0, 0, 2, 0, 0
        @wall 0, -2, 0, 0, 2, 0
        @addStone -1,-1,0
        @addStone -1, 1,0
        @addStone  1,-1,0
        @addStone  1, 1,0
        @delStone 0, 0, 0
                
        @addStone -2,-2,0, Stone.yellow
        @addStone  2,-2,0, Stone.blue
        @addStone -2, 2,0, Stone.green
        @addStone  2, 2,0, Stone.red

        @cube = @addBot  0,0,0, Bot.dodicos, Face.NX
        @addBot -2, 0,1,  Bot.octacube
        @addBot  0, 2,1,  Bot.tubecross
        @addBot  0,-2,1,  Bot.toruscone
        @addBot  2, 0,1,  Bot.knot
                        
    wall: (xs, ys, zs, xe, ye, ze, stone=Stone.gray) ->
        
        for x in [xs..xe]
            for y in [ys..ye]
                for z in [zs..ze]
                    @addStone x, y, z, stone
                    
    delStone: (x,y,z) -> delete @stones[@indexAt x,y,z]
    addStone: (x,y,z, stone=Stone.gray) -> @stones[@indexAt x,y,z] = stone
    stoneAtPos: (v) -> @stones[@indexAtPos v]

    addBot:   (x,y,z, type=Bot.cube, face=Face.PZ) -> 
        p = @roundPos new Vector x,y,z
        index = @indexAtPos p
        @bots[index] = type:type, pos:p, face:face, index:index
    
    botAt:     (x,y,z) -> @bots[@indexAt x,y,z]
    botAtPos:  (v)     -> @bots[@indexAtPos v]
        
    isStoneAt: (x,y,z) -> @stones[@indexAt x,y,z] != undefined
    isItemAt:  (x,y,z) -> @isStoneAt(x,y,z) or @botAt(x,y,z) 
    roundPos:  (v) -> new Vector(v).round()
        
    directionFaceToFace: (fromFaceIndex, toFaceIndex) ->
        
        [fromFace, fromIndex] = @splitFaceIndex fromFaceIndex
        [  toFace,   toIndex] = @splitFaceIndex toFaceIndex
        if fromFace == toFace # flat case : vector to target
            @posAtIndex(fromIndex).to(@posAtIndex toIndex).mul 0.5
        else if fromIndex == toIndex # concave case : flip target face normal
            Vector.normals[(toFace+3)%6].mul 0.3
        else
            Vector.normals[toFace].mul 0.475 # convex case : target face normal
    
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
    splitFaceIndex: (faceIndex) -> [faceIndex >> 28, faceIndex & ((Math.pow 2, 27)-1)]
    stringForFace: (face) ->
        switch face
            when Face.PX then return "PX"
            when Face.PY then return "PY"
            when Face.PZ then return "PZ"
            when Face.NX then return "NX"
            when Face.NY then return "NY"
            when Face.NZ then return "NZ"
            
    stringForFaceIndex: (faceIndex) ->
        [face,index] = @splitFaceIndex faceIndex
        pos = @posAtIndex index
        "#{pos.x} #{pos.y} #{pos.z} #{@stringForFace(face)}"
    
    indexAt: (x,y,z) -> (x+256)+((y+256)<<9)+((z+256)<<18)
    indexAtPos: (v) -> p = @roundPos(v); @indexAt p.x, p.y, p.z
    posAtIndex: (index) -> 
        new Vector 
            x:( index      & 0b111111111)-256
            y:((index>>9 ) & 0b111111111)-256
            z:((index>>18) & 0b111111111)-256
                
    # 000   000  000   0000000   000   000  000      000   0000000   000   000  000000000  
    # 000   000  000  000        000   000  000      000  000        000   000     000     
    # 000000000  000  000  0000  000000000  000      000  000  0000  000000000     000     
    # 000   000  000  000   000  000   000  000      000  000   000  000   000     000     
    # 000   000  000   0000000   000   000  0000000  000   0000000   000   000     000     
    
    removeHighlight: ->
        
        @highlightBot?.highlight?.parent.remove @highlightBot?.highlight
        delete @highlightBot?.highlight
        delete @highlightBot
    
    highlightPos: (v) -> 
        
        p = @roundPos v
        if bot = @botAtPos p
            if bot == @highlightBot
                bot.highlight.position.set p.x, p.y, p.z
                @orientFace bot.highlight, bot.face
                return
            @removeHighlight()
            @highlightBot = bot
                    
            bot.highlight = @construct.highlight bot
        else
            @removeHighlight()
        
    # 00     00   0000000   000   000  00000000  
    # 000   000  000   000  000   000  000       
    # 000000000  000   000   000 000   0000000   
    # 000 0 000  000   000     000     000       
    # 000   000   0000000       0      00000000  
    
    moveBot: (bot, toPos, toFace) ->
        
        fromIndex = bot.index
        toIndex = @indexAtPos toPos
        delete @bots[fromIndex]
        @bots[toIndex] = bot
        
        bot.face = toFace
        bot.index = toIndex
        bot.pos = @roundPos toPos
        bot.mesh.position.set toPos.x, toPos.y, toPos.z
        
        if bot == @cube
            @construct.paths()
        else
            @construct.addPathFromBotToBot @cube, bot
        
        @orientBot bot
        @colorBot bot
        
    orientBot: (bot) -> @orientFace bot.mesh, bot.face
    orientFace: (object, face) ->
        object.quaternion.copy quat().setFromUnitVectors vec(0,0,1), Vector.normals[face]
        
    posBelowBot: (bot) ->  bot.pos.minus Vector.normals[bot.face]
        
    colorBot: (bot) ->
        
        below = @posBelowBot bot
        if stone = @stoneAtPos below
            bot.mesh.material = Materials.bot[stone]
        else
            bot.mesh.material = Materials.botWhite
            
module.exports = World
