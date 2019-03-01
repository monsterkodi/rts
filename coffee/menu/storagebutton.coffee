###
 0000000  000000000   0000000   00000000    0000000    0000000   00000000  0000000    000   000  000000000  000000000   0000000   000   000
000          000     000   000  000   000  000   000  000        000       000   000  000   000     000        000     000   000  0000  000
0000000      000     000   000  0000000    000000000  000  0000  0000000   0000000    000   000     000        000     000   000  000 0 000
     000     000     000   000  000   000  000   000  000   000  000       000   000  000   000     000        000     000   000  000  0000
0000000      000      0000000   000   000  000   000   0000000   00000000  0000000     0000000      000        000      0000000   000   000
###

{ post, clamp, menu, log, _ } = require 'kxk'

{ Stone } = require '../constants'

CanvasButton = require './canvasbutton'
Materials    = require '../materials'
Graph        = require '../graph'
Color        = require '../color'
Boxes        = require '../boxes'

class StorageButton extends CanvasButton

    constructor: (menu) ->
        
        @dirty   = false
        @storage = rts.world.storage[0]
        @box     = [[],[],[],[]]

        super menu.div
        
        @boxes = new Boxes @scene, 4*320, new THREE.BoxBufferGeometry
        @name  = 'Storage'
        
        post.on 'storageChanged', @onStorageChanged 
                                
        for stone in Stone.resources
            @onStorageChanged @storage, stone, @storage.stones[stone]
                                
    click: -> Graph.toggle()
    
    animate: (delta) ->
        
        if @dirty
            @render()
            @dirty = false
                   
    posForStone: (stone, i) ->
        
        cap = @storage.capacity()
        pos = vec stone*1.6-2.7, 0, 0
        l = cap/10
        h = l/2
        pos.y = 1.2*Math.floor (i-1)/l
        pos.y += @stoneSize if (i-1)%l > h-1
        pos.x += @stoneSize if (i-1)%2 == 1
        pos.z += @stoneSize * Math.floor ((i-1)%h)/2 
        pos
            
    onStorageChanged: (storage, stone, amount) =>
                
        return if storage.player != 0
        
        while @box[stone].length < amount
            @box[stone].push @boxes.add stone:stone, size:@stoneSize, pos:@posForStone stone, @box[stone].length+1

        while @box[stone].length > amount
            @boxes.del @box[stone].pop()
                
        @dirty = true
    
    #  0000000   0000000  00000000  000   000  00000000  
    # 000       000       000       0000  000  000       
    # 0000000   000       0000000   000 0 000  0000000   
    #      000  000       000       000  0000  000       
    # 0000000    0000000  00000000  000   000  00000000  
    
    initScene: ->
                
        @scene.background = Color.menu.background
        
        @light = new THREE.DirectionalLight 0xffffff
        @light.position.set 0,10,6
        @scene.add @light
        
        @scene.add new THREE.AmbientLight 0xffffff
        
        @camera.fov = 40
        @camera.position.copy vec(0,2,1).normal().mul 22
            
    highlight: -> 

        @camera.fov = 36
        @render()
    
    unhighlight: ->

        @camera.fov = 40
        @render()
        
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    render: ->

        # log 'render', @storage.capacity(), @box[Stone.red].length, @box[Stone.gelb].length, @box[Stone.blue].length, @box[Stone.white].length
        switch @storage.capacity()
            when 320 then @camera.lookAt vec 0, 5.6, 0
            when 240 then @camera.lookAt vec 0, 6.0, 0
            when 200 then @camera.lookAt vec 0, 6.4, 0
            when 160 then @camera.lookAt vec 0, 6.8, 0
            when 120 then @camera.lookAt vec 0, 7.2, 0
            when  80 then @camera.lookAt vec 0, 7.6, 0
                
        @camera.updateProjectionMatrix()
        
        @boxes.render()
        super()
            
module.exports = StorageButton