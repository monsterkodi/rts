###
 0000000   00000000   0000000   00     00  00000000  000000000  00000000   000   000
000        000       000   000  000   000  000          000     000   000   000 000 
000  0000  0000000   000   000  000000000  0000000      000     0000000      00000  
000   000  000       000   000  000 0 000  000          000     000   000     000   
 0000000   00000000   0000000   000   000  00000000     000     000   000     000   
###

{ deg2rad, log, _ } = require 'kxk'

class Geometry
    
    @cache = {}
    
    @cornerBox: ->
                    
        s = 0.45
        o = 0.5
        i = 0.4
        
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
                
        cube = new THREE.Geometry()
        cube.merge topside
        cube.merge rightside
        cube.merge backside
        cube.merge bottomside
        cube.merge leftside
        cube.merge frontside

        bufg = new THREE.BufferGeometry()
        bufg.fromGeometry cube
        bufg
    
    #  0000000   0000000    0000000  000000000  
    # 000       000   000  000          000     
    # 000       000   000  0000000      000     
    # 000       000   000       000     000     
    #  0000000   0000000   0000000      000     
    
    @frontStone: (h,s) ->

        geom = new THREE.Geometry
        
        geom.vertices.push vec  s,  s,  s
        geom.vertices.push vec -s,  s,  s
        geom.vertices.push vec -s, -s,  s
        geom.vertices.push vec  s, -s,  s

        geom.vertices.push vec  s,  s, -s
        geom.vertices.push vec -s,  s, -s
        geom.vertices.push vec -s, -s, -s
        geom.vertices.push vec  s, -s, -s
        
        geom.faces.push new THREE.Face3 0, 1, 2
        geom.faces.push new THREE.Face3 0, 2, 3

        geom.faces.push new THREE.Face3 0, 5, 1
        geom.faces.push new THREE.Face3 0, 4, 5

        geom.faces.push new THREE.Face3 0, 3, 4
        geom.faces.push new THREE.Face3 3, 7, 4
        
        geom.faces.push new THREE.Face3 1, 5, 2
        geom.faces.push new THREE.Face3 2, 5, 6
        
        geom.translate 0,(h*1.2)+0.5,0
        
        geom.computeFaceNormals()
        geom.computeFlatVertexNormals()
        geom
    
    @smallStone: (h,y) ->

        geom = @frontStone h, 0.25
        f = (y-1)%4
        geom.translate -0.25 + (0<f<3 and 0.5 or 0),-0.25+(y>4 and 0.5 or 0), -0.25 + (f>1 and 0.5 or 0)
        geom
        
    @smallStones: (num) ->
        
        if cached = @cache["smallStones#{num}"]
            return cached
        
        geom = new THREE.Geometry
        for y in [1..num]
            geom.merge @smallStone 0,y
            
        @cache["smallStones#{num}"] = geom
        # log "smallStones#{num}"
        geom
        
    @largeStones: (num) ->
        
        if cached = @cache["largeStones#{num}"]
            return cached
        
        geom = new THREE.Geometry
        for h in [0...num]
            geom.merge @frontStone h, 0.5
            
        @cache["largeStones#{num}"] = geom
        
        geom
        
    @stonesMissing: (stone, have, cost) ->
        
        ceil  = 8*Math.ceil have/8
        small = ceil-have
            
        merg = new THREE.Geometry 
        @stoneAmount stone, cost-ceil, merg
        merg.translate 0, ceil/8*1.2, 0
            
        if small
            for y in [9-small..8]
                geom = @smallStone ceil/8-1, y
                geom.translate stone*1.5-2.3,0,0
                merg.merge geom
                
        new THREE.BufferGeometry().fromGeometry merg
    
    @stoneAmount: (stone, amount, mergeWith) ->
        
        return if amount == 0
        
        if cached = @cache["stoneAmount_#{stone}_#{amount}"]
            return cached
        
        merg  = new THREE.Geometry 
        
        big   = Math.floor amount/8
        small = amount - big*8
        
        if 0 < small < 8
            merg.merge @smallStones small
            merg.translate 0,big*1.2,0
                
        merg.merge @largeStones big if big
        merg.translate stone*1.5-2.3, 0, 0 
            
        if mergeWith
            mergeWith.merge merg
            mergeWith
        else
            bufg = new THREE.BufferGeometry().fromGeometry merg
            @cache["stoneAmount_#{stone}_#{amount}"] = bufg
            # log "stoneAmount_#{stone}_#{amount}"
            bufg
    
    #  0000000  000000000   0000000   000000000  00000000  
    # 000          000     000   000     000     000       
    # 0000000      000     000000000     000     0000000   
    #      000     000     000   000     000     000       
    # 0000000      000     000   000     000     00000000  
    
    @state: (state) ->
        
        switch state
            when 'off'  
                geom = new THREE.Geometry
                geom.vertices.push vec -1.5,  2,  1.5
                geom.vertices.push vec -1.5, -2,  1.5
                geom.vertices.push vec  2.0,  0,  1.5
                geom.vertices.push vec -1.5,  2,  0
                geom.vertices.push vec  2.0,  0,  0
                geom.faces.push new THREE.Face3 0, 1, 2
                geom.faces.push new THREE.Face3 3, 0, 4
                geom.faces.push new THREE.Face3 0, 2, 4
                geom.computeFaceNormals()
                geom.computeFlatVertexNormals()
                
            when 'on' 
                left  = new THREE.BoxGeometry 2,4,1.5
                left.translate -1.5, 0, 0     
                right = new THREE.BoxGeometry 2,4,1.5
                right.translate 1.5, 0, 0
                geom  = new THREE.Geometry
                geom.merge left
                geom.merge right
            else
                geom = new THREE.BoxGeometry 1.8,1.8,1.8
                
        new THREE.BufferGeometry().fromGeometry geom
        
    # 000000000  00000000    0000000   0000000    00000000  
    #    000     000   000  000   000  000   000  000       
    #    000     0000000    000000000  000   000  0000000   
    #    000     000   000  000   000  000   000  000       
    #    000     000   000  000   000  0000000    00000000  
    
    @trade: (stone, amount) ->
        
        return if amount <= 0
        
        merg = new THREE.Geometry 
        
        for i in [0...amount]
            geom = new THREE.BoxGeometry 1.8,1.8,1.8
            switch amount
                when 1 then
                when 2
                    switch i
                        when 0 then geom.translate -1, 0, 0
                        when 1 then geom.translate  1, 0, 0
                else
                    switch i
                        when 0 then geom.translate -1, -1, 0
                        when 1 then geom.translate  1, -1, 0
                        when 2 then geom.translate  1,  1, 0
                        when 3 then geom.translate -1,  1, 0
            merg.merge geom
            
        new THREE.BufferGeometry().fromGeometry merg
        
    # 0000000     0000000   000   000  
    # 000   000  000   000   000 000   
    # 0000000    000   000    00000    
    # 000   000  000   000   000 000   
    # 0000000     0000000   000   000  
    
    @box: (size=1, x=0, y=0, z=0) ->
        
        geom = new THREE.BoxGeometry size, size, size
        geom.translate x, y, z
        geom
        
    @sphere: (size=1, x=0, y=0, z=0) ->
        
        geom = new THREE.SphereGeometry size, 6, 6
        geom.computeFaceNormals()
        geom.computeFlatVertexNormals()
        geom.translate x, y, z
        geom

    #  0000000  000000000   0000000   00000000   
    # 000          000     000   000  000   000  
    # 0000000      000     000000000  0000000    
    #      000     000     000   000  000   000  
    # 0000000      000     000   000  000   000  
    
    @star: (size=1, x=0, y=0, z=0) ->
        
        geom = new THREE.Geometry
        
        geom.vertices.push vec(   0,  0.5, 0).normal().mul 0.5*size
        geom.vertices.push vec(-0.5, -0.3, 0).normal().mul 0.5*size
        geom.vertices.push vec( 0.5, -0.3, 0).normal().mul 0.5*size
        geom.faces.push new THREE.Face3 0, 1, 2        

        geom.vertices.push vec(   0, -0.5, 0).normal().mul 0.5*size
        geom.vertices.push vec(-0.5,  0.3, 0).normal().mul 0.5*size
        geom.vertices.push vec( 0.5,  0.3, 0).normal().mul 0.5*size
        geom.faces.push new THREE.Face3 3, 5, 4        

        geom.computeFaceNormals()
        geom.computeFlatVertexNormals()
        geom.translate x, y, z
        geom
        
    #  0000000  00000000   00000000  00000000  0000000    
    # 000       000   000  000       000       000   000  
    # 0000000   00000000   0000000   0000000   000   000  
    #      000  000        000       000       000   000  
    # 0000000   000        00000000  00000000  0000000    
    
    @speed: (size=1, x=0, y=0, z=0) ->
        
        geom = new THREE.Geometry
        geom.vertices.push vec -size/2,  size/2, size/4
        geom.vertices.push vec -size/2, -size/2, size/4
        geom.vertices.push vec  size/2,  0,      size/4
        geom.vertices.push vec -size/2,  size/2, 0
        geom.vertices.push vec  size/2,  0,      0
        geom.faces.push new THREE.Face3 0, 1, 2
        geom.faces.push new THREE.Face3 3, 0, 4
        geom.faces.push new THREE.Face3 0, 2, 4
        geom.computeFaceNormals()
        geom.computeFlatVertexNormals()
        geom.translate x, y, z
        geom
        
    # 000000000  000   000  0000000    00000000  
    #    000     000   000  000   000  000       
    #    000     000   000  0000000    0000000   
    #    000     000   000  000   000  000       
    #    000      0000000   0000000    00000000  
    
    @tube: (size=1, x=0, y=0, z=0) ->
        
        geom1 = new THREE.BoxGeometry size/10, size, size/10
        geom1.rotateY deg2rad 45
        geom2 = new THREE.BoxGeometry size, size/10, size/10
        geom2.rotateX deg2rad 45
        geom1.merge geom2
        geom1.translate x, y, z
        geom1
        
    # 00000000   000      000   000   0000000  
    # 000   000  000      000   000  000       
    # 00000000   000      000   000  0000000   
    # 000        000      000   000       000  
    # 000        0000000   0000000   0000000   
    
    @plus: (size=1, x=0, y=0, z=0) ->

        geom1 = new THREE.BoxGeometry size/5, size, size/5
        geom2 = new THREE.BoxGeometry size, size/5, size/5
        geom1.merge geom2
        geom1.translate x, y, z
        geom1
        
    # 00000000   000       0000000   000   000  
    # 000   000  000      000   000   000 000   
    # 00000000   000      000000000    00000    
    # 000        000      000   000     000     
    # 000        0000000  000   000     000     
    
    @play: (size=1, x=0, y=0, z=0) ->
        
        geom = new THREE.Geometry
        geom.vertices.push vec -size/2,  size/2, size/4
        geom.vertices.push vec -size/2, -size/2, size/4
        geom.vertices.push vec  size/2,  0,      size/4
        geom.vertices.push vec -size/2,  size/2, 0
        geom.vertices.push vec  size/2,  0,      0
        geom.faces.push new THREE.Face3 0, 1, 2
        geom.faces.push new THREE.Face3 3, 0, 4
        geom.faces.push new THREE.Face3 0, 2, 4
        geom.computeFaceNormals()
        geom.computeFlatVertexNormals()
        geom.translate x, y, z
        geom
        
    # 00000000    0000000   000   000   0000000  00000000  
    # 000   000  000   000  000   000  000       000       
    # 00000000   000000000  000   000  0000000   0000000   
    # 000        000   000  000   000       000  000       
    # 000        000   000   0000000   0000000   00000000  
    
    @pause: (size=1, x=0, y=0, z=0) ->
        
        geom1  = new THREE.BoxGeometry size/3,size,size/4
        geom1.translate -size/6, 0, 0     
        geom2 = new THREE.BoxGeometry size/3,size,size/4
        geom2.translate size/6, 0, 0
        geom1.merge geom2
        geom1.translate x, y, z
        geom1
            
module.exports = Geometry
