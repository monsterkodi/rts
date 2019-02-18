###
 0000000  000000000   0000000   00000000    0000000    0000000   00000000
000          000     000   000  000   000  000   000  000        000     
0000000      000     000   000  0000000    000000000  000  0000  0000000 
     000     000     000   000  000   000  000   000  000   000  000     
0000000      000      0000000   000   000  000   000   0000000   00000000
###

{ post, clamp, menu, _ } = require 'kxk'

{ Stone } = require './constants'

CanvasButton = require './menu/canvasbutton'
Materials    = require './materials'
Geometry     = require './geometry'
Graph        = require './graph'
Color        = require './color'

class Storage extends CanvasButton

    constructor: (menu) ->
        
        @name     = 'Storage'
        @dirty    = true
        @stones   = _.clone state.storage.stones
        @temp     = [0,0,0,0]

        @resetBalance()
        
        super menu.div
        
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

        for stone in Stone.resources
            
            @meshes[stone]?.parent?.remove @meshes[stone]
            delete @meshes[stone]
            
            if @stones[stone]
                bufg = Geometry.stoneAmount stone, @stones[stone]
                mesh = new THREE.Mesh bufg, Materials.cost[stone]
                @scene.add mesh
                @meshes[stone] = mesh
            
        super()
            
module.exports = Storage
