###
 0000000   00000000   0000000   00     00  00000000  000000000  00000000   000   000
000        000       000   000  000   000  000          000     000   000   000 000 
000  0000  0000000   000   000  000000000  0000000      000     0000000      00000  
000   000  000       000   000  000 0 000  000          000     000   000     000   
 0000000   00000000   0000000   000   000  00000000     000     000   000     000   
###

{ deg2rad, log, _ } = require 'kxk'

{ Bot } = require './constants'

class Geometry
    
    @cache = {}
    
    @cornerBox: (size=1, x=0, y=0, z=0) ->
                    
        o = size/2
        s = 0.9*o
        i = 0.8*o
        
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
        bufg.translate x, y, z
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
    
    @tube: (size=1, radius=0.1, x=0, y=0, z=0) ->
        
        geom1 = new THREE.BoxGeometry size*radius, size, size*radius
        geom1.rotateY deg2rad 45
        geom2 = new THREE.BoxGeometry size, size*radius, size*radius
        geom2.rotateX deg2rad 45
        geom1.merge geom2
        geom1.translate x, y, z
        geom1
        
    @buildGuide: ->
        
        geom = new THREE.ConeGeometry 0.2, 0.35, 12
        geom.rotateX deg2rad 90
        geom.computeFlatVertexNormals()
        geom
        
    @coordinateCross: (s=0.05, x=0, y=0, z=0) -> 
        
        geom = new THREE.Geometry
        geom.merge new THREE.BoxGeometry 1000, s, s
        geom.merge new THREE.BoxGeometry s, 1000, s
        geom.merge new THREE.BoxGeometry s, s, 1000
        geom.translate x, y, z
        geom
        
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
        
    @botPaused: ->

        size = 0.1
        geom1 = new THREE.BoxGeometry size/2,size,size/4
        geom1.translate -size/3, 0, 0     
        geom2 = new THREE.BoxGeometry size/2,size,size/4
        geom2.translate size/3, 0, 0
        
        geom = new THREE.Geometry
        geom.merge geom1
        geom.merge geom2
        geom.translate 0.15,0.12,0.24
        geom.rotateY deg2rad 5
        geom.rotateX deg2rad 45
        geom
        
    @call: ->
        
        construct = rts.world.construct

        geom = new THREE.Geometry
        b = construct.botGeoms[construct.geomForBotType Bot.base].clone()
        s = 0.75
        b.scale s,s,s
        b.rotateX deg2rad -45
        geom.merge b

        s = 0.5
        b = construct.botGeoms[construct.geomForBotType Bot.mine].clone()
        b.scale s,s,s
        b.rotateX deg2rad -45
        b.translate 0.35, 0.35, 0
        geom.merge b

        b = construct.botGeoms[construct.geomForBotType Bot.mine].clone()
        b.scale s,s,s
        b.rotateX deg2rad -45
        b.translate -0.35, 0.35, 0
        geom.merge b

        b = construct.botGeoms[construct.geomForBotType Bot.mine].clone()
        b.scale s,s,s
        b.rotateX deg2rad -45
        b.translate -0.35, -0.35, 0
        geom.merge b
        
        b = construct.botGeoms[construct.geomForBotType Bot.mine].clone()
        b.scale s,s,s
        b.rotateX deg2rad -45
        b.translate 0.35, -0.35, 0
        geom.merge b
        
        b = Geometry.tube 1, 0.02
        b.rotateZ deg2rad 45
        geom.merge b
        
        bufg = new THREE.BufferGeometry().fromGeometry geom
            
module.exports = Geometry
