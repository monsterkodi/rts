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

class World

    constructor: (@scene) ->
        
        @stones = {}
        
        for z in [-10..0]
        # for z in [0..0]
            for y in [-5..5]
                @wall -10,y*2,z*2, 10,y*2,z*2
                @wall y*2,-10,z*2, y*2,10,z*2
             
        @addStone  0,-1,0, Stone.red
        @addStone -2,-1,0, Stone.yellow
        @addStone  2,-1,0, Stone.blue
        @addStone  0,1,0, Stone.green
        @addStone -2,1,0, Stone.white
        @addStone  2,1,0, Stone.black
        
        @construct()
        
    wall: (xs, ys, zs, xe, ye, ze, stone=Stone.gray) ->
        
        for x in [xs..xe]
            for y in [ys..ye]
                for z in [zs..ze]
                    @addStone x, y, z, stone
                    
    delStone: (x,y,z) ->
        
        delete @stones[@stoneIndex x,y,z]
                    
    addStone: (x,y,z, stone=Stone.gray) ->
        
        @stones[@stoneIndex x,y,z] = stone
        
    stoneAt: (x,y,z) -> @stones[@stoneIndex x,y,z] != undefined
        
    stoneIndex: (x,y,z) -> x+Stone.max/2+(y+Stone.max/2)*Stone.max+(z+Stone.max/2)*Stone.max*Stone.max
    stonePos: (index) ->
            x = index % Stone.max
            index -= x
            x -= Stone.max/2
            y = index % (Stone.max * Stone.max)
            index -= y
            y /= Stone.max
            y -= Stone.max/2
            z = index / (Stone.max * Stone.max) - Stone.max/2
            x:x, y:y, z:z
    
    construct: ->
                                         
        #  0000000  000   000  0000000    00000000   0000000    
        # 000       000   000  000   000  000       000         
        # 000       000   000  0000000    0000000   0000000     
        # 000       000   000  000   000  000            000    
        #  0000000   0000000   0000000    00000000  0000000     
        
        materials = [
            new THREE.MeshPhongMaterial color:0x111111
            new THREE.MeshPhongMaterial color:0xdd0000
            new THREE.MeshPhongMaterial color:0x008800
            new THREE.MeshPhongMaterial color:0x0000ff
            new THREE.MeshPhongMaterial color:0xffff00
            new THREE.MeshPhongMaterial color:0x000000
            new THREE.MeshPhongMaterial color:0xffffff
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
            p = @stonePos index
            cube = new THREE.Geometry()
            if not @stoneAt p.x, p.y, p.z+1 then cube.merge topside
            if not @stoneAt p.x+1, p.y, p.z then cube.merge rightside
            if not @stoneAt p.x, p.y+1, p.z then cube.merge backside
            if not @stoneAt p.x, p.y, p.z-1 then cube.merge bottomside
            if not @stoneAt p.x-1, p.y, p.z then cube.merge leftside
            if not @stoneAt p.x, p.y-1, p.z then cube.merge frontside
            cube.translate p.x, p.y, p.z
            stonesides[stone].merge cube
            
        for stone in [Stone.gray..Stone.white]            
            
            bufgeo = new THREE.BufferGeometry()
            bufgeo.fromGeometry stonesides[stone]
            
            mesh = new THREE.Mesh bufgeo, materials[stone]
            mesh.castShadow = true
            mesh.receiveShadow = true
            @scene.add mesh
        
            
module.exports = World
