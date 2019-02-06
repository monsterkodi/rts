###
000   000   0000000   00000000   000      0000000  
000 0 000  000   000  000   000  000      000   000
000000000  000   000  0000000    000      000   000
000   000  000   000  000   000  000      000   000
00     00   0000000   000   000  0000000  0000000  
###

{ deg2rad, log, _ } = require 'kxk'

THREE = require 'three'
AStar  = require './astar'
Vector = require './lib/vector'

Stone = 
    gray:   0
    red:    1
    green:  2
    blue:   3
    yellow: 4
    black:  5
    white:  6
    max:    1000
    
Face = 
    PX: 0
    PY: 1
    PZ: 2
    NX: 3
    NY: 4
    NZ: 5
    
Bot =
    cube:       1
    cone:       2
    sphere:     3
    torus:      4
    icosa:      5
    dodeca:     6
    tetra:      7
    octa:       8
    cylinder:   9
    knot:       10
    dodicos:    11
    octacube:   12
    toruscone:  13
    tubecross:  14

Materials = 
    highlight:  new THREE.MeshLambertMaterial  color:0xffffff, emissive:0xffffff, side:THREE.BackSide
    botGray:    new THREE.MeshStandardMaterial color:0xccccdd, metalness: 0.9, roughness: 0.5
    botWhite:   new THREE.MeshStandardMaterial color:0xccccdd, metalness: 0.9, roughness: 0.5 
    path:       new THREE.MeshStandardMaterial color:0xbbbbbb, metalness: 0.9, roughness: 0.5 
    stone: [   
                new THREE.MeshPhongMaterial    color:0x111111 # gray
                new THREE.MeshStandardMaterial color:0x880000 # red
                new THREE.MeshStandardMaterial color:0x008800 # green
                new THREE.MeshStandardMaterial color:0x000088 # blue
                new THREE.MeshStandardMaterial color:0xffff00 # yellow
                new THREE.MeshStandardMaterial color:0x000000 # black
                new THREE.MeshStandardMaterial color:0xffffff # white
    ]
    bot: [   
                new THREE.MeshStandardMaterial color:0x111111 # gray
                new THREE.MeshStandardMaterial color:0xdd0000 # red
                new THREE.MeshStandardMaterial color:0x008800 # green
                new THREE.MeshStandardMaterial color:0x0000ff # blue
                new THREE.MeshStandardMaterial color:0xffff00 # yellow
                new THREE.MeshStandardMaterial color:0x000000 # black
                new THREE.MeshStandardMaterial color:0xffffff # white
    ]
    
class World
    
    constructor: (@scene) ->
        
        @stones = {}
        @bots = {}
        
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

        sphere = new THREE.SphereGeometry 0.1, 6, 6
        sphere.computeFaceNormals()
        sphere.rotateX deg2rad 90
        sphere.computeFlatVertexNormals()
        
        @baseDot = new THREE.Mesh sphere, Materials.path
        @baseDot.castShadow = true
        @baseDot.receiveShadow = true
        @scene.add @baseDot 
        @updateBaseDot()
        
        @astar = new AStar @
        
        @initBotGeoms()
        @constructBots()
        @constructCubes()
        @constructPaths()
        
    updateBaseDot: ->
        
        dp = @cube.pos.minus Vector.normals[@cube.face].mul 0.35
        @baseDot.position.set dp.x, dp.y, dp.z
        @baseDot.quaternion.copy new THREE.Quaternion().setFromUnitVectors new THREE.Vector3(0, 0, 1), Vector.normals[@cube.face]
        
    # 00000000    0000000   000000000  000   000  
    # 000   000  000   000     000     000   000  
    # 00000000   000000000     000     000000000  
    # 000        000   000     000     000   000  
    # 000        000   000     000     000   000  
    
    constructPaths: ->
        
        for index,bot of @bots
            continue if bot == @cube
            @addPathFromBotToBot @cube, bot
            
    addPathFromBotToBot: (from, to) ->
        
        to.path?.parent?.remove to.path
        path = @astar.findPath @faceIndex(from.face, from.index), @faceIndex(to.face, to.index)
        if path
            to.path = @addPath path
        else
            delete to.path
            
    directionFaceToFace: (fromFaceIndex, toFaceIndex) ->
        
        [fromFace, fromIndex] = @splitFaceIndex fromFaceIndex
        [  toFace,   toIndex] = @splitFaceIndex toFaceIndex
        if fromFace == toFace # flat case : vector to target
            @posAtIndex(fromIndex).to(@posAtIndex toIndex).mul 0.5
        else if fromIndex == toIndex # concave case : flip target face normal
            Vector.normals[(toFace+3)%6].mul 0.3
        else
            Vector.normals[toFace].mul 0.475 # convex case : target face normal
            
    tubePoints: (path) ->
        
        points = []
        [lastFace, lastIndex] = @splitFaceIndex path[0]
        lastPos = @posAtIndex lastIndex
        
        aboveFace   = 0.35
        
        lastPos.sub Vector.normals[lastFace].mul aboveFace
        points.push face:lastFace, index:lastIndex, pos:new Vector lastPos.x, lastPos.y, lastPos.z
        for i in [1...path.length]
            [nextFace, nextIndex] = @splitFaceIndex path[i]
            nextPos = @posAtIndex nextIndex
            nextPos.sub Vector.normals[nextFace].mul aboveFace
            pos1 = lastPos.plus @directionFaceToFace path[i-1], path[i]
            pos2 = nextPos.plus @directionFaceToFace path[i], path[i-1]
            points.push face:lastFace, index:lastIndex, pos:new Vector pos1.x, pos1.y, pos1.z
            points.push face:nextFace, index:nextIndex, pos:new Vector pos2.x, pos2.y, pos2.z
            points.push face:nextFace, index:nextIndex, pos:new Vector nextPos.x, nextPos.y, nextPos.z
            [lastFace, lastIndex] = [nextFace, nextIndex]
            lastPos = nextPos
        points
            
    addTubeFaces: (p1, p2) -> 
        
        if p1.face != p2.face
            
            if p1.index == p2.index # convex
                n2 = Vector.normals[p1.face].mul(0.025)
                n3 = Vector.normals[p2.face].mul(0.025)
                
                n1 = n2.plus Vector.normals[p2.face].mul(0.02)
                n4 = n3.plus Vector.normals[p1.face].mul(0.02)
            else
                n1 = Vector.normals[p1.face].mul(0.025)
                n4 = Vector.normals[p2.face].mul(0.025)
                
                n2 = n1.plus Vector.normals[p2.face].mul(0.02)
                n3 = n4.plus Vector.normals[p1.face].mul(0.02)
        else
            n1 = n2 = n3 = n4 = Vector.normals[p1.face].mul 0.025
            
        n5 = n6 = n7 = n8 = Vector.normals[p1.face].cross(p1.pos.to(p2.pos)).normal().mul 0.025
        
        tube = new THREE.Geometry
        
        tube.vertices.push new THREE.Vector3 p1.pos.x+n1.x,  p1.pos.y+n1.y, p1.pos.z+n1.z
        tube.vertices.push new THREE.Vector3 p1.pos.x-n2.x,  p1.pos.y-n2.y, p1.pos.z-n2.z
        tube.vertices.push new THREE.Vector3 p2.pos.x-n3.x,  p2.pos.y-n3.y, p2.pos.z-n3.z
        tube.vertices.push new THREE.Vector3 p2.pos.x+n4.x,  p2.pos.y+n4.y, p2.pos.z+n4.z

        tube.vertices.push new THREE.Vector3 p1.pos.x+n5.x,  p1.pos.y+n5.y, p1.pos.z+n5.z
        tube.vertices.push new THREE.Vector3 p1.pos.x-n6.x,  p1.pos.y-n6.y, p1.pos.z-n6.z
        tube.vertices.push new THREE.Vector3 p2.pos.x-n7.x,  p2.pos.y-n7.y, p2.pos.z-n7.z
        tube.vertices.push new THREE.Vector3 p2.pos.x+n8.x,  p2.pos.y+n8.y, p2.pos.z+n8.z
        
        tube.faces.push new THREE.Face3 0, 5, 6
        tube.faces.push new THREE.Face3 6, 3, 0
        tube.faces.push new THREE.Face3 4, 0, 3
        tube.faces.push new THREE.Face3 3, 7, 4

        tube.faces.push new THREE.Face3 5, 1, 2
        tube.faces.push new THREE.Face3 5, 2, 6 
        tube.faces.push new THREE.Face3 4, 7, 2
        tube.faces.push new THREE.Face3 4, 2, 1
        
        tube
        
    addPath: (path) ->
        
        tube = new THREE.Geometry
        
        points = @tubePoints path    
        for i in [1...points.length]
            tube.merge @addTubeFaces points[i-1], points[i]
            
        sphere = new THREE.SphereGeometry 0.1, 6, 6
        if points[0].face in [Face.PZ, Face.NZ]
            sphere.rotateX deg2rad 90
        else if points[0].face in [Face.PX, Face.NX]
            sphere.rotateZ deg2rad 90
        sphere.translate points[0].pos.x, points[0].pos.y, points[0].pos.z
        sphere.faceVertexUvs = [[]]
        tube.merge sphere
             
        tube.computeFaceNormals()
        tube.computeFlatVertexNormals()
        
        tubeBuffer = new THREE.BufferGeometry
        tubeBuffer.fromGeometry tube
        mesh = new THREE.Mesh tubeBuffer, Materials.path
        mesh.castShadow = true
                        
        @scene.add mesh
        mesh
        
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
        
            geom = new THREE.BufferGeometry 
            geom.fromGeometry @botGeoms[bot.type]
            geom.scale 1.1, 1.1, 1.1
            
            mesh = new THREE.Mesh geom, Materials.highlight
            mesh.position.set p.x, p.y, p.z
            @orientFace mesh, bot.face
            @scene.add mesh
            
            bot.highlight = mesh
        else
            @removeHighlight()
        
    # 0000000     0000000   000000000   0000000  
    # 000   000  000   000     000     000       
    # 0000000    000   000     000     0000000   
    # 000   000  000   000     000          000  
    # 0000000     0000000      000     0000000   
    
    initBotGeoms: ->
                
        @botGeoms = [
            new THREE.Geometry
            new THREE.BoxGeometry 0.5, 0.5, 0.5            # cube
            new THREE.ConeGeometry 0.25, 0.5, 12           # cone
            new THREE.SphereGeometry 0.25, 12, 12          # sphere
            new THREE.TorusGeometry 0.2, 0.125, 8, 12      # torus
            new THREE.IcosahedronGeometry 0.3, 0           # icosa
            new THREE.DodecahedronGeometry 0.3, 0          # dodeca
            new THREE.TetrahedronGeometry 0.5, 0           # tetra
            new THREE.OctahedronGeometry 0.3, 0            # octa
            new THREE.CylinderGeometry 0.25, 0.25, 0.5, 12 # cylinder
            new THREE.TorusKnotGeometry 0.15, 0.1          # knot
            new THREE.DodecahedronGeometry 0.275, 0        # dodicos
            new THREE.BoxGeometry 0.25, 0.25, 0.25         # octacube
            new THREE.TorusGeometry 0.2, 0.075, 8, 12      # toruscone
            new THREE.CylinderGeometry 0.1, 0.1, 0.5, 12   # tubecross
        ]
        
        @botGeoms[Bot.dodicos].rotateX deg2rad 60
        icos = new THREE.IcosahedronGeometry 0.275, 0
        icos.rotateY deg2rad 60
        icos.rotateZ deg2rad -18
        @botGeoms[Bot.dodicos].merge icos
                
        cone = new THREE.ConeGeometry 0.25, 0.5, 12
        cone.rotateX deg2rad 90
        @botGeoms[Bot.toruscone].merge cone
        
        tube = new THREE.CylinderGeometry 0.1, 0.1, 0.5, 12
        tube.rotateX deg2rad 90
        @botGeoms[Bot.tubecross].merge tube
        tube.rotateY deg2rad 90
        @botGeoms[Bot.tubecross].merge tube
        
        @botGeoms[Bot.octacube].merge new THREE.OctahedronGeometry 0.25, 0
                
        @botGeoms[Bot.cone].rotateX deg2rad 90
        @botGeoms[Bot.sphere].rotateX deg2rad 90
        @botGeoms[Bot.cylinder].rotateX deg2rad 90
        @botGeoms[Bot.dodeca].rotateX deg2rad 60
        @botGeoms[Bot.icosa].rotateY deg2rad 60
        @botGeoms[Bot.icosa].rotateZ deg2rad 18

        for bot in [Bot.cube..Bot.tubecross]
            @botGeoms[bot].computeFaceNormals()
            @botGeoms[bot].computeFlatVertexNormals()
    
    constructBots: ->
                        
        for index,bot of @bots
            p = @posAtIndex index
            
            mesh = new THREE.Mesh @botGeoms[bot.type], Materials.botGray
            mesh.receiveShadow = true
            mesh.castShadow = true
            mesh.position.set p.x, p.y, p.z
            @scene.add mesh
            bot.mesh = mesh
            @colorBot bot
            @orientBot bot
             
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
            @constructPaths()
            @updateBaseDot()
        else
            @addPathFromBotToBot @cube, bot
        
        @orientBot bot
        @colorBot bot
        
    orientBot: (bot) -> @orientFace bot.mesh, bot.face
    orientFace: (object, face) ->
        object.quaternion.copy new THREE.Quaternion().setFromUnitVectors new THREE.Vector3(0,0,1), Vector.normals[face]
        
    posBelowBot: (bot) ->  bot.pos.minus Vector.normals[bot.face]
        
    colorBot: (bot) ->
        
        # if bot == @cube
            # bot.mesh.material = Materials.botWhite
            # return
            
        below = @posBelowBot bot
        if stone = @stoneAtPos below
            bot.mesh.material = Materials.bot[stone]
        else
            bot.mesh.material = Materials.botWhite
        
    #  0000000  000   000  0000000    00000000   0000000    
    # 000       000   000  000   000  000       000         
    # 000       000   000  0000000    0000000   0000000     
    # 000       000   000  000   000  000            000    
    #  0000000   0000000   0000000    00000000  0000000     
        
    constructCubes: ->
                    
        s = 0.5
        o = 0.55
        i = 0.45
        
        topside = new THREE.Geometry()
        
        topside.vertices.push new THREE.Vector3  s,  s, s
        topside.vertices.push new THREE.Vector3 -s,  s, s
        topside.vertices.push new THREE.Vector3 -s, -s, s
        topside.vertices.push new THREE.Vector3  s, -s, s

        topside.vertices.push new THREE.Vector3  i,  i, o
        topside.vertices.push new THREE.Vector3 -i,  i, o
        topside.vertices.push new THREE.Vector3 -i, -i, o
        topside.vertices.push new THREE.Vector3  i, -i, o
        
        topside.faces.push new THREE.Face3 4, 5, 6
        topside.faces.push new THREE.Face3 4, 6, 7

        topside.faces.push new THREE.Face3 0, 1, 5
        topside.faces.push new THREE.Face3 0, 5, 4
        
        topside.faces.push new THREE.Face3 1, 2, 6
        topside.faces.push new THREE.Face3 1, 6, 5

        topside.faces.push new THREE.Face3 2, 3, 7
        topside.faces.push new THREE.Face3 2, 7, 6
        
        topside.faces.push new THREE.Face3 0, 4, 7
        topside.faces.push new THREE.Face3 0, 7, 3
        
        topside.computeFaceNormals()
        topside.computeFlatVertexNormals()
        
        rightside = new THREE.Geometry()
        rightside.copy topside
        rightside.rotateY deg2rad 90
        
        leftside = new THREE.Geometry()
        leftside.copy topside
        leftside.rotateY deg2rad -90

        backside = new THREE.Geometry()
        backside.copy topside
        backside.rotateX deg2rad -90

        frontside = new THREE.Geometry()
        frontside.copy topside
        frontside.rotateX deg2rad 90

        bottomside = new THREE.Geometry()
        bottomside.copy topside
        bottomside.rotateX deg2rad -180
        
        stonesides = []
        for stone in [Stone.gray..Stone.white]
            stonesides.push new THREE.Geometry
        
        for index,stone of @stones
            p = @posAtIndex index
            cube = new THREE.Geometry()
            if not @isStoneAt p.x, p.y, p.z+1 then cube.merge topside
            if not @isStoneAt p.x+1, p.y, p.z then cube.merge rightside
            if not @isStoneAt p.x, p.y+1, p.z then cube.merge backside
            if not @isStoneAt p.x, p.y, p.z-1 then cube.merge bottomside
            if not @isStoneAt p.x-1, p.y, p.z then cube.merge leftside
            if not @isStoneAt p.x, p.y-1, p.z then cube.merge frontside
            cube.translate p.x, p.y, p.z
            stonesides[stone].merge cube
            
        for stone in [Stone.gray..Stone.white]            
            
            bufgeo = new THREE.BufferGeometry()
            bufgeo.fromGeometry stonesides[stone]
            
            mesh = new THREE.Mesh bufgeo, Materials.stone[stone]
            mesh.receiveShadow = true
            mesh.castShadow = true
            @scene.add mesh
            
module.exports = World
