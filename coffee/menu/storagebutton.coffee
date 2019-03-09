###
 0000000  000000000   0000000   00000000    0000000    0000000   00000000  0000000    000   000  000000000  000000000   0000000   000   000
000          000     000   000  000   000  000   000  000        000       000   000  000   000     000        000     000   000  0000  000
0000000      000     000   000  0000000    000000000  000  0000  0000000   0000000    000   000     000        000     000   000  000 0 000
     000     000     000   000  000   000  000   000  000   000  000       000   000  000   000     000        000     000   000  000  0000
0000000      000      0000000   000   000  000   000   0000000   00000000  0000000     0000000      000        000      0000000   000   000
###

CanvasButton = require './canvasbutton'
Graph        = require '../graph'
Boxes        = require '../boxes'

class StorageButton extends CanvasButton

    constructor: (@menu) ->
        
        @storage = rts.world.storage[0]
        @box     = [[],[],[],[]]

        @vec = vec()
        
        @normFov  = 40
        @highFov  = 36
        @lightPos = vec 0,10,6
        @lookPos  = vec 0, 7.6, 0
        @camPos   = vec(0,2,1).normal().mul 22
        
        super @menu.div
        
        @boxes = new Boxes @scene, 4*320, new THREE.BoxBufferGeometry
        @name  = 'StorageButton'
                
        post.on 'storageChanged', @onStorageChanged 
                                
        for stone in Stone.resources
            @onStorageChanged @storage, stone, @storage.stones[stone]
                                
    click: -> Graph.toggle()
                       
    posForStone: (stone, i) ->
        
        cap = @storage.capacity()
        @vec.set stone*1.6-2.7, 0, 0
        l = cap/10
        h = l/2
        @vec.y = 1.2*Math.floor (i-1)/l
        @vec.y += @stoneSize if (i-1)%l > h-1
        @vec.x += @stoneSize if (i-1)%2 == 1
        @vec.z += @stoneSize * Math.floor ((i-1)%h)/2 
        @vec
            
    onStorageChanged: (storage, stone, amount) =>
                
        return if storage.player != 0
        
        while @box[stone].length < amount
            @box[stone].push @boxes.add stone:stone, size:@stoneSize, pos:@posForStone stone, @box[stone].length+1

        while @box[stone].length > amount
            @boxes.del @box[stone].pop()
                
        @update()
    
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    render: ->

        return if not @dirty
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
        
        super
            
module.exports = StorageButton
