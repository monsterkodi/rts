###
 0000000   0000000   000   000   0000000  000000000  00000000   000   000   0000000  000000000
000       000   000  0000  000  000          000     000   000  000   000  000          000   
000       000   000  000 0 000  0000000      000     0000000    000   000  000          000   
000       000   000  000  0000       000     000     000   000  000   000  000          000   
 0000000   0000000   000   000  0000000      000     000   000   0000000    0000000     000   
###

{ deg2rad, log, _ } = require 'kxk'

THREE     = require 'three'
AStar     = require './lib/astar'
Vector    = require './lib/vector'
Materials = require './materials'

{ Stone, Bot, Face } = require './constants'

class Construct

    constructor: (@world) ->
        
        @astar = new AStar @world
                
    # 00000000    0000000   000000000  000   000  
    # 000   000  000   000     000     000   000  
    # 00000000   000000000     000     000000000  
    # 000        000   000     000     000   000  
    # 000        000   000     000     000   000  
    
    paths: ->
        
        for index, bot of @world.bots
            continue if bot == @world.cube
            @pathFromTo @world.cube, bot
            
        @updateBaseDot()
            
    pathFromTo: (from, to) ->
        
        to.path?.parent?.remove to.path
        path = @astar.findPath @world.faceIndex(from.face, from.index), @world.faceIndex(to.face, to.index)
        if path
            to.path = @addPath path
        else
            delete to.path
                        
    addPath: (path) ->
        
        tube = new THREE.Geometry
        
        points = @tubePoints path    
        for i in [1...points.length]
            tube.merge @tubeFaces points[i-1], points[i]
            
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
                        
        @world.scene.add mesh
        mesh
            
    # 000000000  000   000  0000000    00000000  
    #    000     000   000  000   000  000       
    #    000     000   000  0000000    0000000   
    #    000     000   000  000   000  000       
    #    000      0000000   0000000    00000000  
    
    tubePoints: (path) ->
        
        points = []
        [lastFace, lastIndex] = @world.splitFaceIndex path[0]
        lastPos = @world.posAtIndex lastIndex
        
        aboveFace = 0.35
        
        lastPos.sub Vector.normals[lastFace].mul aboveFace
        points.push i:0, face:lastFace, index:lastIndex, pos:new Vector lastPos.x, lastPos.y, lastPos.z
        for i in [1...path.length]
            [nextFace, nextIndex] = @world.splitFaceIndex path[i]
            nextPos = @world.posAtIndex nextIndex
            nextPos.sub Vector.normals[nextFace].mul aboveFace
            if lastFace != nextFace
                pos1 = lastPos.plus @world.directionFaceToFace path[i-1], path[i]
                pos2 = nextPos.plus @world.directionFaceToFace path[i], path[i-1]
                points.push i:1, face:lastFace, index:lastIndex, pos:new Vector pos1.x, pos1.y, pos1.z
                points.push i:1, face:nextFace, index:nextIndex, pos:new Vector pos2.x, pos2.y, pos2.z
            points.push i:0, face:nextFace, index:nextIndex, pos:new Vector nextPos.x, nextPos.y, nextPos.z
            [lastFace, lastIndex] = [nextFace, nextIndex]
            lastPos = nextPos
        points
            
    tubeFaces: (p1, p2) -> 
        
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
        
        if p1.i == 0
            d = p2.pos.to p1.pos
            d.normalize().scale 0.025
            n5 = n5.plus d
            n6 = n6.minus d
        if p2.i == 0
            d = p1.pos.to p2.pos
            d.normalize().scale 0.025
            n7 = n7.minus d
            n8 = n8.plus d
        
        tube = new THREE.Geometry
        
        tube.vertices.push vec p1.pos.x+n1.x,  p1.pos.y+n1.y, p1.pos.z+n1.z
        tube.vertices.push vec p1.pos.x-n2.x,  p1.pos.y-n2.y, p1.pos.z-n2.z
        tube.vertices.push vec p2.pos.x-n3.x,  p2.pos.y-n3.y, p2.pos.z-n3.z
        tube.vertices.push vec p2.pos.x+n4.x,  p2.pos.y+n4.y, p2.pos.z+n4.z
        
        tube.vertices.push vec p1.pos.x+n5.x,  p1.pos.y+n5.y, p1.pos.z+n5.z
        tube.vertices.push vec p1.pos.x-n6.x,  p1.pos.y-n6.y, p1.pos.z-n6.z
        tube.vertices.push vec p2.pos.x-n7.x,  p2.pos.y-n7.y, p2.pos.z-n7.z
        tube.vertices.push vec p2.pos.x+n8.x,  p2.pos.y+n8.y, p2.pos.z+n8.z
        
        tube.faces.push new THREE.Face3 0, 5, 6
        tube.faces.push new THREE.Face3 6, 3, 0
        tube.faces.push new THREE.Face3 4, 0, 3
        tube.faces.push new THREE.Face3 3, 7, 4

        tube.faces.push new THREE.Face3 5, 1, 2
        tube.faces.push new THREE.Face3 5, 2, 6 
        tube.faces.push new THREE.Face3 4, 7, 2
        tube.faces.push new THREE.Face3 4, 2, 1
        
        tube
                
# 0000000     0000000   000000000   0000000   00000000   0000000   00     00   0000000  
# 000   000  000   000     000     000        000       000   000  000   000  000       
# 0000000    000   000     000     000  0000  0000000   000   000  000000000  0000000   
# 000   000  000   000     000     000   000  000       000   000  000 0 000       000  
# 0000000     0000000      000      0000000   00000000   0000000   000   000  0000000   

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
        
        knot = new THREE.TorusKnotGeometry 0.1, 0.075
        knot.translate 0,0,-0.175
        @botGeoms[Bot.knot].merge knot
        
        @botGeoms[Bot.cone].rotateX deg2rad 90
        @botGeoms[Bot.sphere].rotateX deg2rad 90
        @botGeoms[Bot.cylinder].rotateX deg2rad 90
        @botGeoms[Bot.dodeca].rotateX deg2rad 60
        @botGeoms[Bot.icosa].rotateY deg2rad 60
        @botGeoms[Bot.icosa].rotateZ deg2rad 18

        for bot in [Bot.cube..Bot.tubecross]
            @botGeoms[bot].computeFaceNormals()
            @botGeoms[bot].computeFlatVertexNormals()
    
    # 0000000     0000000   000000000   0000000  
    # 000   000  000   000     000     000       
    # 0000000    000   000     000     0000000   
    # 000   000  000   000     000          000  
    # 0000000     0000000      000     0000000   
    
    bots: ->
                        
        for index,bot of @world.bots
            p = @world.posAtIndex index
            
            mesh = new THREE.Mesh @botGeoms[bot.type], Materials.botGray
            mesh.receiveShadow = true
            mesh.castShadow = true
            mesh.position.set p.x, p.y, p.z
            mesh.bot = bot.type
            @world.scene.add mesh
            bot.mesh = mesh
            @colorBot bot
            @orientBot bot


    updateBot: (bot) ->
        
        bot.mesh.position.set bot.pos.x, bot.pos.y, bot.pos.z
        @orientBot bot
        @colorBot bot
        
    orientBot: (bot) -> @orientFace bot.mesh, bot.face
    orientFace: (obj, face) -> obj.quaternion.copy quat().setFromUnitVectors vec(0,0,1), Vector.normals[face]
        
    colorBot: (bot) ->
        
        below = @world.posBelowBot bot
        if stone = @world.stoneAtPos below
            bot.mesh.material = Materials.bot[stone]
        else
            bot.mesh.material = Materials.botWhite
            
    # 0000000     0000000    0000000  00000000  0000000     0000000   000000000  
    # 000   000  000   000  000       000       000   000  000   000     000     
    # 0000000    000000000  0000000   0000000   000   000  000   000     000     
    # 000   000  000   000       000  000       000   000  000   000     000     
    # 0000000    000   000  0000000   00000000  0000000     0000000      000     
    
    baseDot: ->
        
        sphere = new THREE.SphereGeometry 0.1, 6, 6
        sphere.computeFaceNormals()
        sphere.rotateX deg2rad 90
        sphere.computeFlatVertexNormals()
        
        @bdot = new THREE.Mesh sphere, Materials.path
        @bdot.castShadow = true
        @bdot.receiveShadow = true
        @world.scene.add @bdot
        
    updateBaseDot: ->
        
        dp = @world.cube.pos.minus Vector.normals[@world.cube.face].mul 0.35
        @bdot.position.set dp.x, dp.y, dp.z
        @bdot.quaternion.copy quat().setFromUnitVectors vec(0, 0, 1), Vector.normals[@world.cube.face]
            
    # 000   000  000   0000000   000   000  000      000   0000000   000   000  000000000  
    # 000   000  000  000        000   000  000      000  000        000   000     000     
    # 000000000  000  000  0000  000000000  000      000  000  0000  000000000     000     
    # 000   000  000  000   000  000   000  000      000  000   000  000   000     000     
    # 000   000  000   0000000   000   000  0000000  000   0000000   000   000     000     
    
    highlight: (bot) ->
        
        geom = new THREE.BufferGeometry 
        geom.fromGeometry @botGeoms[bot.type]
        s = 1.05
        geom.scale s,s,s
        
        mesh = new THREE.Mesh geom, Materials.highlight
        p = bot.pos
        mesh.position.set p.x, p.y, p.z
        @orientFace mesh, bot.face
        @world.scene.add mesh
        mesh
            
    #  0000000  000000000   0000000   000   000  00000000   0000000    
    # 000          000     000   000  0000  000  000       000         
    # 0000000      000     000   000  000 0 000  0000000   0000000     
    #      000     000     000   000  000  0000  000            000    
    # 0000000      000      0000000   000   000  00000000  0000000     
    
    stones: ->
                    
        s = 0.5
        o = 0.55
        i = 0.45
        
        topside = new THREE.Geometry()
        
        topside.vertices.push vec  s,  s, s
        topside.vertices.push vec -s,  s, s
        topside.vertices.push vec -s, -s, s
        topside.vertices.push vec  s, -s, s

        topside.vertices.push vec  i,  i, o
        topside.vertices.push vec -i,  i, o
        topside.vertices.push vec -i, -i, o
        topside.vertices.push vec  i, -i, o
        
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
        
        for index,stone of @world.stones
            p = @world.posAtIndex index
            cube = new THREE.Geometry()
            if not @world.isStoneAt p.x, p.y, p.z+1 then cube.merge topside
            if not @world.isStoneAt p.x+1, p.y, p.z then cube.merge rightside
            if not @world.isStoneAt p.x, p.y+1, p.z then cube.merge backside
            if not @world.isStoneAt p.x, p.y, p.z-1 then cube.merge bottomside
            if not @world.isStoneAt p.x-1, p.y, p.z then cube.merge leftside
            if not @world.isStoneAt p.x, p.y-1, p.z then cube.merge frontside
            cube.translate p.x, p.y, p.z
            stonesides[stone].merge cube
            
        for stone in [Stone.gray..Stone.white]            
            
            bufgeo = new THREE.BufferGeometry()
            bufgeo.fromGeometry stonesides[stone]
            
            mesh = new THREE.Mesh bufgeo, Materials.stone[stone]
            mesh.receiveShadow = true
            mesh.castShadow = true
            mesh.stone = stone
            @world.scene.add mesh

module.exports = Construct
