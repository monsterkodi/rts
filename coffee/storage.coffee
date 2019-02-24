###
 0000000  000000000   0000000   00000000    0000000    0000000   00000000
000          000     000   000  000   000  000   000  000        000     
0000000      000     000   000  0000000    000000000  000  0000  0000000 
     000     000     000   000  000   000  000   000  000   000  000     
0000000      000      0000000   000   000  000   000   0000000   00000000
###

{ post, clamp, menu, log, _ } = require 'kxk'

{ Stone } = require './constants'

CanvasButton = require './menu/canvasbutton'
Materials    = require './materials'
Graph        = require './graph'
Color        = require './color'
Boxes        = require './boxes'

class Storage extends CanvasButton

    constructor: (menu) ->
        
        @dirty     = false
        @stones    = [0,0,0,0]
        @temp      = [0,0,0,0]
        @box       = [[],[],[],[]]

        @resetBalance()
        
        super menu.div
        
        @boxes = new Boxes @scene, 16*4*80, new THREE.BoxBufferGeometry
        @name  = 'Storage'
        
        for stone in Stone.resources
            @add stone, state.storage.stones[stone], 'init'
            
        @render()
        
    resetBalance: -> @balance = gains:[0,0,0,0], spent:[0,0,0,0]
        
    capacity: -> state.storage.capacity
        
    click: -> Graph.toggle()
    
    animate: (delta) ->
        
        if @dirty
            @render()
            post.emit 'storageChanged'
            @dirty = false
               
    has: (stone, amount) -> @stones[stone] >= amount
            
    canTake: (stone, amount=1) -> 
        
        return 0 if stone == Stone.gray
        clamp 0, amount, @capacity() - @stones[stone] - @temp[stone]

    willSend: (stone) -> @temp[stone] += 1
        
    deductBuild: -> 
        
        if @canAfford state.science.build.cost
            @deduct state.science.build.cost
            @dirty = true
            return true
        false
        
    canAfford: (cost) ->
        
        for stone in Stone.resources
            if @stones[stone] < cost[stone]
                return false
        true
                
    clear: -> @deduct @stones, 'clear'
    fill:  -> @deduct [-@capacity(), -@capacity(), -@capacity(), -@capacity()], 'fill'

    deduct: (cost, reason) ->
        
        for stone in Stone.resources
            @add stone, -cost[stone], reason
    
    add: (stone, amount=1, reason=null) ->
        
        oldStones = @stones[stone]
        
        @stones[stone] += amount
        @stones[stone] = clamp 0, @capacity(), @stones[stone]
        
        if not reason
            delta = @stones[stone]-oldStones
            if delta > 0
                @balance.gains[stone] += delta
            else 
                @balance.spent[stone] -= delta

        while @box[stone].length < @stones[stone]
            @box[stone].push @boxes.add stone:stone, size:@stoneSize, pos:@posForStone stone, @box[stone].length+1

        while @box[stone].length > @stones[stone]
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
        
        @camera.position.copy vec(0,2,1).normal().mul 22
        @camera.lookAt vec 0,7.6,0
                
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    render: ->

        @boxes.render()
        super()
            
module.exports = Storage
