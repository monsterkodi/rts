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
        
        for z in [-5..0]
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
        
        rightside = new THREE.Geometry()
        rightside.copy topside
        rightside.rotateY deg2rad 90

        backside = new THREE.Geometry()
        backside.copy topside
        backside.rotateX deg2rad 90
        
        halfcube = new THREE.Geometry()
        halfcube.merge topside
        halfcube.merge rightside
        halfcube.merge backside
        
        cubehalf = new THREE.Geometry()
        cubehalf.copy halfcube
        cubehalf.rotateX deg2rad 180
        cubehalf.rotateZ deg2rad 90

        cube = new THREE.Geometry()
        cube.merge cubehalf
        cube.merge halfcube
                
        bufgeo = new THREE.BufferGeometry()
        bufgeo.fromGeometry cube
        bufgeo.center()
        
        bufgeo.computeBoundingSphere()
        
        for index,stone of @stones
            pos = @stonePos index
            mesh = new THREE.Mesh bufgeo, materials[stone]
            mesh.position.set pos.x, pos.y, pos.z
            mesh.castShadow = true
            mesh.receiveShadow = true
            @scene.add mesh
            
module.exports = World
