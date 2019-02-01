###
000   000   0000000   00000000   000      0000000  
000 0 000  000   000  000   000  000      000   000
000000000  000   000  0000000    000      000   000
000   000  000   000  000   000  000      000   000
00     00   0000000   000   000  0000000  0000000  
###

{ log, _ } = require 'kxk'

THREE = require 'three'

class World

    constructor: (@scene) ->
                                 
        #  0000000  000   000  0000000    00000000   0000000    
        # 000       000   000  000   000  000       000         
        # 000       000   000  0000000    0000000   0000000     
        # 000       000   000  000   000  000            000    
        #  0000000   0000000   0000000    00000000  0000000     
        
        material = new THREE.MeshPhongMaterial 
            color:          0xff0000
            side:           THREE.FrontSide
            transparent:    true
            opacity:        0.85
            shininess:      0

        w = 11
        h = 7
        for x in [0...w]
            for y in [0...h]
                geom = new THREE.BoxGeometry 0.8, 0.8, 0.8
                geom.center()
                mesh = new THREE.Mesh geom, material
                mesh.position.set x-Math.floor(w/2), y-Math.floor(h/2), 0
                @scene.add mesh
        
module.exports = World
