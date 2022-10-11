###
 0000000   00000000   0000000   00     00  00000000  000000000  00000000   000   000
000        000       000   000  000   000  000          000     000   000   000 000 
000  0000  0000000   000   000  000000000  0000000      000     0000000      00000  
000   000  000       000   000  000 0 000  000          000     000   000     000   
 0000000   00000000   0000000   000   000  00000000     000     000   000     000   
###

require "../three/examples/js/utils/BufferGeometryUtils"

class Geometry
    
    @cache = {}
    
    @cornerBoxGeom: (size=1, x=0, y=0, z=0) ->
                    
        o = size/2
        s = 0.9*o
        i = 0.8*o
        
        topside = new THREE.BufferGeometry()
        
        vertices = new Float32Array [
             i,  i, o
            -i,  i, o
            -i, -i, o
             
             i,  i, o
            -i, -i, o
             i, -i, o

             s,  s, s
            -s,  s, s
            -i,  i, o
             
             s,  s, s
            -i,  i, o
             i,  i, o

            -s,  s, s
            -s, -s, s
            -i, -i, o

            -s,  s, s
            -i, -i, o
            -i,  i, o
             
            -s, -s, s
             s, -s, s
             i, -i, o

            -s, -s, s
             i, -i, o
            -i, -i, o
             
             s,  s, s
             i,  i, o
             i, -i, o

             s,  s, s
             i, -i, o
             s, -s, s
        ]
        
        topside.setAttribute 'position' new THREE.BufferAttribute vertices, 3

        rightside = new THREE.BufferGeometry()
        rightside.copy topside
        rightside.rotateY deg2rad 90

        leftside = new THREE.BufferGeometry()
        leftside.copy topside
        leftside.rotateY deg2rad -90

        backside = new THREE.BufferGeometry()
        backside.copy topside
        backside.rotateX deg2rad -90

        frontside = new THREE.BufferGeometry()
        frontside.copy topside
        frontside.rotateX deg2rad 90

        bottomside = new THREE.BufferGeometry()
        bottomside.copy topside
        bottomside.rotateX deg2rad -180
                
        cube = THREE.BufferGeometryUtils.mergeBufferGeometries [topside, rightside, backside, bottomside, leftside, frontside]
        cube.translate x, y, z
        cube.computeVertexNormals()
        cube.computeBoundingSphere()
        cube
        
    @cornerBox: (size=1, x=0, y=0, z=0) ->
        
        @cornerBoxGeom size, x, y, z
    
    #  0000000  000000000   0000000   000000000  00000000  
    # 000          000     000   000     000     000       
    # 0000000      000     000000000     000     0000000   
    #      000     000     000   000     000     000       
    # 0000000      000     000   000     000     00000000  
    
    @state: (state) ->
        
        switch state
            when 'off'  
                geom = new THREE.BufferGeometry
                vertices = new Float32Array [
                    -1.5,  2,  1.5
                    -1.5, -2,  1.5
                     2.0,  0,  1.5

                    -1.5,  2,  0
                    -1.5,  2,  1.5
                     2.0,  0,  0

                    -1.5,  2,  1.5
                     2.0,  0,  1.5
                     2.0,  0,  0
                    ]
                geom.setAttribute 'position' new THREE.BufferAttribute vertices, 3
                 
            when 'on' 
                left  = new THREE.BoxGeometry 2,4,1.5
                left.translate -1.5, 0, 0     
                right = new THREE.BoxGeometry 2,4,1.5
                right.translate 1.5, 0, 0
                geom  = THREE.BufferGeometryUtils.mergeBufferGeometries [
                    left
                    right
                ]
            else
                geom = new THREE.BoxGeometry 1.8,1.8,1.8
                
        geom
        
    # 0000000     0000000   000   000  
    # 000   000  000   000   000 000   
    # 0000000    000   000    00000    
    # 000   000  000   000   000 000   
    # 0000000     0000000   000   000  
    
    @box: (size=1, x=0, y=0, z=0) ->
        
        geom = new THREE.BoxGeometry size, size, size
        geom.translate x, y, z
        geom
        
    #  0000000  00000000   000   000  00000000  00000000   00000000  
    # 000       000   000  000   000  000       000   000  000       
    # 0000000   00000000   000000000  0000000   0000000    0000000   
    #      000  000        000   000  000       000   000  000       
    # 0000000   000        000   000  00000000  000   000  00000000  
    
    @sphere: (size=1, x=0, y=0, z=0) ->
        
        geom = new THREE.SphereGeometry size, 6, 6
        geom.translate x, y, z
        geom

module.exports = Geometry
