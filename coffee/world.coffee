###
000   000   0000000   00000000   000      0000000  
000 0 000  000   000  000   000  000      000   000
000000000  000   000  0000000    000      000   000
000   000  000   000  000   000  000      000   000
00     00   0000000   000   000  0000000  0000000  
###

{ deg2rad, log, _ } = require 'kxk'

THREE = require 'three'

class World

    constructor: (@scene) ->
                                 
        #  0000000  000   000  0000000    00000000   0000000    
        # 000       000   000  000   000  000       000         
        # 000       000   000  0000000    0000000   0000000     
        # 000       000   000  000   000  000            000    
        #  0000000   0000000   0000000    00000000  0000000     
        
        material_gray   = new THREE.MeshPhongMaterial color:0x111111
        material_red    = new THREE.MeshPhongMaterial color:0xff0000
        material_blue   = new THREE.MeshPhongMaterial color:0x0000ff
        material_green  = new THREE.MeshPhongMaterial color:0x004400
        material_white  = new THREE.MeshPhongMaterial color:0xffffff
        material_yellow = new THREE.MeshPhongMaterial color:0xffff00
        material_black  = new THREE.MeshPhongMaterial color:0x000000
            
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
        
        bufgeo.computeBoundingSphere()
        
        w = 9
        h = 5
        for x in [0...w]
            for y in [0...h]
                mesh = new THREE.Mesh bufgeo, material_gray
                mesh.position.set x-Math.floor(w/2), y-Math.floor(h/2), 0
                mesh.castShadow = true
                mesh.receiveShadow = true
                @scene.add mesh

        w = 11
        h = 7
        for x in [0...w]
            for y in [0...h]
                mesh = new THREE.Mesh bufgeo, material_gray
                mesh.position.set x-Math.floor(w/2), y-Math.floor(h/2), -2
                mesh.castShadow = true
                mesh.receiveShadow = true
                @scene.add mesh
                
        mesh = new THREE.Mesh bufgeo, material_red
        mesh.castShadow = true
        mesh.receiveShadow = true
        mesh.position.set 0, 0, 1
        @scene.add mesh

        mesh = new THREE.Mesh bufgeo, material_blue
        mesh.castShadow = true
        mesh.receiveShadow = true
        mesh.position.set 2, 1, 2
        @scene.add mesh
        
        mesh = new THREE.Mesh bufgeo, material_green
        mesh.castShadow = true
        mesh.receiveShadow = true
        mesh.position.set 2, 1, 3
        @scene.add mesh

        mesh = new THREE.Mesh bufgeo, material_yellow
        mesh.castShadow = true
        mesh.receiveShadow = true
        mesh.position.set -2, 1, 3
        @scene.add mesh
        
        
module.exports = World
