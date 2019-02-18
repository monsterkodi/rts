###
 0000000   0000000   000   000   0000000  000000000  00000000   000   000   0000000  000000000
000       000   000  0000  000  000          000     000   000  000   000  000          000   
000       000   000  000 0 000  0000000      000     0000000    000   000  000          000   
000       000   000  000  0000       000     000     000   000  000   000  000          000   
 0000000   0000000   000   000  0000000      000     000   000   0000000    0000000     000   
###

{ deg2rad, log, _ } = require 'kxk'

THREE     = require 'three'
Vector    = require './lib/vector'
Materials = require './materials'

{ Stone, Bot, Geom, Face } = require './constants'

class Construct

    constructor: (@world) ->
        
        @segmentMesh = null
        @stoneMeshes = {}
                        
    # 000000000  000   000  0000000    00000000  
    #    000     000   000  000   000  000       
    #    000     000   000  0000000    0000000   
    #    000     000   000  000   000  000       
    #    000      0000000   0000000    00000000  
         
    tubes: ->
        
        @segmentMesh?.parent?.remove @segmentMesh
        
        tube = new THREE.Geometry
        
        for seg in @world.tubes.getSegments()
            if seg.points.length >= 2
                for i in [1...seg.points.length]
                    tube.merge @tubeFaces seg.points[i-1], seg.points[i]
            
        tube.computeFaceNormals()
        tube.computeFlatVertexNormals()
        
        tubeBuffer = new THREE.BufferGeometry
        tubeBuffer.fromGeometry tube
        mesh = new THREE.Mesh tubeBuffer, Materials.path
        mesh.castShadow = true
                        
        @world.scene.add mesh
        
        @segmentMesh = mesh
        
        mesh
                
    tubeFaces: (p1, p2) -> 
        
        if p1.face != p2.face
            
            if p1.index == p2.index # convex
                n2 = Vector.normals[p1.face].mul(0.025)
                n3 = Vector.normals[p2.face].mul(0.025)
                
                n1 = n2.plus Vector.normals[p2.face].mul(0.02)
                n4 = n3.plus Vector.normals[p1.face].mul(0.02)
            else # concave
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
        
        @botGeoms[Geom.dodicos].rotateX deg2rad 60
        icos = new THREE.IcosahedronGeometry 0.275, 0
        icos.rotateY deg2rad 60
        icos.rotateZ deg2rad -18
        @botGeoms[Geom.dodicos].merge icos
                
        cone = new THREE.ConeGeometry 0.25, 0.5, 12
        cone.rotateX deg2rad 90
        @botGeoms[Geom.toruscone].merge cone
        
        tube = new THREE.CylinderGeometry 0.1, 0.1, 0.5, 12
        tube.rotateX deg2rad 90
        @botGeoms[Geom.tubecross].merge tube
        tube.rotateY deg2rad 90
        @botGeoms[Geom.tubecross].merge tube
        
        @botGeoms[Geom.octacube].merge new THREE.OctahedronGeometry 0.25, 0
        
        knot = new THREE.TorusKnotGeometry 0.1, 0.075
        knot.translate 0,0,-0.175
        @botGeoms[Geom.knot].merge knot
        
        @botGeoms[Geom.cone].rotateX deg2rad 90
        @botGeoms[Geom.sphere].rotateX deg2rad 90
        @botGeoms[Geom.cylinder].rotateX deg2rad 90
        @botGeoms[Geom.dodeca].rotateX deg2rad 60
        @botGeoms[Geom.icosa].rotateY deg2rad 60
        @botGeoms[Geom.icosa].rotateZ deg2rad 18

        for bot in [Geom.cube..Geom.tubecross]
            @botGeoms[bot].computeFaceNormals()
            @botGeoms[bot].computeFlatVertexNormals()
    
    # 0000000     0000000   000000000   0000000  
    # 000   000  000   000     000     000       
    # 0000000    000   000     000     0000000   
    # 000   000  000   000     000          000  
    # 0000000     0000000      000     0000000   
    
    geomForBot: (bot) -> @geomForBotType bot.type
    geomForBotType: (type) ->
        switch type
            when Bot.base  then Geom.dodicos
            when Bot.mine  then Geom.octacube
            when Bot.build then Geom.tubecross
            when Bot.trade then Geom.toruscone
            when Bot.brain then Geom.knot
    
    bots: ->
                        
        for index,bot of @world.bots
            
            @botAtPos bot, @world.posAtIndex index
            
    botAtPos: (bot, pos) ->
        
        mesh = new THREE.Mesh @botGeoms[@geomForBot bot], Materials.bot[Stone.gray]
        mesh.receiveShadow = true
        mesh.castShadow = true
        mesh.position.copy pos
        mesh.bot = bot.type # needed for intersection test
        @world.scene.add mesh
        bot.mesh = mesh
        
        @dot bot
        @updateBot bot

    updateBot: (bot) ->
        
        bot.mesh.position.copy bot.pos
        bot.highlight?.position.copy bot.pos
        @orientBot bot
        @colorBot bot
        
    orientFace: (obj, face) -> obj.quaternion.copy quat().setFromUnitVectors vec(0,0,1), Vector.normals[face]
    
    orientBot: (bot) -> 
        
        @orientFace bot.mesh, bot.face
        @orientFace bot.dot,  bot.face
        bot.dot.position.copy bot.pos.minus Vector.normals[bot.face].mul 0.35
        
    colorBot: (bot) ->
        
        stone = @world.stoneBelowBot bot
        # log 'colorBot', Bot.string(bot.type), bot.pos, @world.posBelowBot(bot), Stone.string(@world.stoneBelowBot bot)
        if stone in Stone.resources
            bot.mesh.material = Materials.bot[stone]
        else
            bot.mesh.material = Materials.bot[Stone.gray]
            
    # 0000000     0000000   000000000  
    # 000   000  000   000     000     
    # 000   000  000   000     000     
    # 000   000  000   000     000     
    # 0000000     0000000      000     
    
    dot: (bot) ->
        
        sphere = new THREE.SphereGeometry 0.1, 6, 6
        sphere.computeFaceNormals()
        sphere.rotateX deg2rad 90
        sphere.computeFlatVertexNormals()
        
        bot.dot = new THREE.Mesh sphere, Materials.path
        bot.dot.castShadow = true
        bot.dot.receiveShadow = true
        @world.scene.add bot.dot
        
    # 000   000  000   0000000   000   000  000      000   0000000   000   000  000000000  
    # 000   000  000  000        000   000  000      000  000        000   000     000     
    # 000000000  000  000  0000  000000000  000      000  000  0000  000000000     000     
    # 000   000  000  000   000  000   000  000      000  000   000  000   000     000     
    # 000   000  000   0000000   000   000  0000000  000   0000000   000   000     000     
    
    highlight: (bot) ->
        # log 'highlight'
        geom = new THREE.BufferGeometry 
        geom.fromGeometry @botGeoms[@geomForBot bot]
        s = 1.05
        geom.scale s,s,s
        
        mesh = new THREE.Mesh geom, Materials.highlight
        mesh.position.copy bot.pos
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
        for stone in Stone.all
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
            
        for stone in Stone.all
            
            @stoneMeshes[stone]?.parent.remove @stoneMeshes[stone] 
            bufgeo = new THREE.BufferGeometry()
            bufgeo.fromGeometry stonesides[stone]
            
            mesh = new THREE.Mesh bufgeo, Materials.stone[stone]
            mesh.receiveShadow = true
            mesh.castShadow = true
            mesh.stone = stone
            @world.scene.add mesh            
            @stoneMeshes[stone] = mesh

module.exports = Construct
