###
000   000   0000000   00000000   000      0000000  
000 0 000  000   000  000   000  000      000   000
000000000  000   000  0000000    000      000   000
000   000  000   000  000   000  000      000   000
00     00   0000000   000   000  0000000  0000000  
###

{ deg2rad, log, _ } = require 'kxk'

THREE = require 'three'

Stone = 
    gray:   0
    red:    1
    green:  2
    blue:   3
    yellow: 4
    black:  5
    white:  6
    max:    1000
    
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

class World

    constructor: (@scene) ->
        
        @stones = {}
        @bots = {}
        
        # # for z in [-5..0]
        # for z in [0..0]
            # for y in [-10..10]
                # @wall -40,y*4,z*2, 40,y*4,z*2
                # @wall y*4,-40,z*2, y*4,40,z*2
  
        @wall -3, -3, 0, 3, 3, 0
                
        @addStone -2,-2,0, Stone.yellow
        @addStone  2,-2,0, Stone.blue
        @addStone -2, 2,0, Stone.white
        @addStone  2, 2,0, Stone.red

        @addBot -2,-2,1,  Bot.sphere
        @addBot  2,-2,1,  Bot.torus
        @addBot -2, 2,1,  Bot.cube
        @addBot  2, 2,1,  Bot.dodeca
                          
        @addBot  2, 0,1,  Bot.cone
        @addBot  0,-2,1,  Bot.cylinder
        @addBot  0, 0,1,  Bot.octa
        @addBot -2, 0,1,  Bot.icosa
        @addBot  0, 2,1,  Bot.knot
        
        @constructBots()
        @constructCubes()
        
    wall: (xs, ys, zs, xe, ye, ze, stone=Stone.gray) ->
        
        for x in [xs..xe]
            for y in [ys..ye]
                for z in [zs..ze]
                    @addStone x, y, z, stone
                    
    delStone: (x,y,z) -> delete @stones[@cellIndex x,y,z]
    addStone: (x,y,z, stone=Stone.gray) -> @stones[@cellIndex x,y,z] = stone
    addBot:   (x,y,z, bot=Bot.cube) -> @bots[@cellIndex x,y,z] = bot
        
    isStoneAt: (x,y,z) -> @stones[@cellIndex x,y,z] != undefined
    isItemAt:  (x,y,z) -> @isStoneAt(x,y,z) or @botAt(x,y,z) 
    botAt:     (x,y,z) -> @bots[@cellIndex x,y,z]
        
    cellIndex: (x,y,z) -> (x+512)+((y+512)<<10)+((z+512)<<20)
    cellPos:   (index) -> 
        x:( index      & 0b1111111111)-512
        y:((index>>10) & 0b1111111111)-512
        z:((index>>20) & 0b1111111111)-512
    
    # 0000000     0000000   000000000   0000000  
    # 000   000  000   000     000     000       
    # 0000000    000   000     000     0000000   
    # 000   000  000   000     000          000  
    # 0000000     0000000      000     0000000   
    
    constructBots: ->
        
        materials = [
            new THREE.MeshStandardMaterial color:0x000000, metalness: 0.9, roughness: 0.5
            new THREE.MeshPhongMaterial color:0xffffff  # cube
            new THREE.MeshStandardMaterial color:0xffffff, metalness: 0.9, roughness: 0.5 # cone
            new THREE.MeshStandardMaterial color:0xffff00, metalness: 0.5, roughness: 0.5 # sphere
            new THREE.MeshStandardMaterial color:0x0000ff, metalness: 0.5, roughness: 0.5 # torus
            new THREE.MeshStandardMaterial color:0xffffff, metalness: 0.9, roughness: 0.5 # icosa
            new THREE.MeshStandardMaterial color:0xff0000, metalness: 0.5, roughness: 0.5 # dodeca
            new THREE.MeshStandardMaterial color:0xffffff, metalness: 0.9, roughness: 0.5 # tetra
            new THREE.MeshStandardMaterial color:0xffffff, metalness: 0.9, roughness: 0.5 # octa
            new THREE.MeshStandardMaterial color:0xffffff, metalness: 0.9, roughness: 0.5 # cylinder
            new THREE.MeshStandardMaterial color:0xffffff, metalness: 0.5, roughness: 0.5 # knot
        ]       
        
        geoms = [
            new THREE.Geometry
            new THREE.BoxGeometry 0.6, 0.6, 0.6          # cube
            new THREE.ConeGeometry 0.35, 0.6, 12         # cone
            new THREE.SphereGeometry 0.35, 12, 12        # sphere
            new THREE.TorusGeometry 0.3, 0.15, 8, 12     # torus
            new THREE.IcosahedronGeometry 0.4, 0         # icosa
            new THREE.DodecahedronGeometry 0.4, 0        # dodeca
            new THREE.TetrahedronGeometry 0.5, 0         # tetra
            new THREE.OctahedronGeometry 0.4, 0          # octa
            new THREE.CylinderGeometry 0.3, 0.3, 0.5, 12 # cylinder
            new THREE.TorusKnotGeometry 0.2, 0.1         # knot
        ]
        
        geoms[Bot.cone].rotateX deg2rad 90
        geoms[Bot.sphere].rotateX deg2rad 90
        geoms[Bot.cylinder].rotateX deg2rad 90
        geoms[Bot.dodeca].rotateX deg2rad 60
        geoms[Bot.icosa].rotateY deg2rad 60
        geoms[Bot.icosa].rotateZ deg2rad 18

        for bot in [Bot.cube..Bot.knot]
            geoms[bot].computeFaceNormals()
            geoms[bot].computeFlatVertexNormals()
        
        for index,bot of @bots
            p = @cellPos index
        
            mesh = new THREE.Mesh geoms[bot], materials[bot]
            mesh.receiveShadow = true
            mesh.castShadow = true
            mesh.position.set p.x, p.y, p.z
            @scene.add mesh
                                         
    #  0000000  000   000  0000000    00000000   0000000    
    # 000       000   000  000   000  000       000         
    # 000       000   000  0000000    0000000   0000000     
    # 000       000   000  000   000  000            000    
    #  0000000   0000000   0000000    00000000  0000000     
        
    constructCubes: ->
        
        materials = [
            new THREE.MeshPhongMaterial color:0x111111 # gray
            new THREE.MeshPhongMaterial color:0xdd0000 # red
            new THREE.MeshPhongMaterial color:0x008800 # green
            new THREE.MeshPhongMaterial color:0x0000ff # blue
            new THREE.MeshPhongMaterial color:0xffff00 # yellow
            new THREE.MeshPhongMaterial color:0x000000 # black
            new THREE.MeshPhongMaterial color:0xffffff # white
            ]
            
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
            p = @cellPos index
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
            
            mesh = new THREE.Mesh bufgeo, materials[stone]
            mesh.receiveShadow = true
            mesh.castShadow = true
            @scene.add mesh
            
module.exports = World
