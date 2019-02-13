###
 0000000  000000000   0000000   00000000    0000000    0000000   00000000
000          000     000   000  000   000  000   000  000        000     
0000000      000     000   000  0000000    000000000  000  0000  0000000 
     000     000     000   000  000   000  000   000  000   000  000     
0000000      000      0000000   000   000  000   000   0000000   00000000
###

{ post, deg2rad, elem, log, _ } = require 'kxk'

{ Stone } = require './constants'

CanvasButton = require './menu/canvasbutton'
Materials    = require './materials'

class Storage extends CanvasButton

    constructor: (menu) ->
        
        super menu.div
        
        @name = 'Storage'
        
        @dirty     = true
        @stones    = [500,500,0,0]
        @temp      = [0,0,0,0]
        @maxStones = 1000
              
        @camera.updateProjectionMatrix()    
        
    click: -> log 'storage click'
    
    animate: (delta) ->
        
        if @dirty
            @render()
            post.emit 'storageChanged'
            @dirty = false
                
    canTake: (stone) -> 
        
        return false if stone == Stone.gray
        @stones[stone] + @temp[stone] < @maxStones

    willSend: (stone) -> @temp[stone] += 1
        
    canBuild: -> 
        
        if @stones[Stone.white] >= 20
            @stones[Stone.white] -= 20
            @dirty = true
            return true
        false
        
    canAfford: (cost) ->
        
        for stone in Stone.resources
            if @stones[stone] < cost[stone]
                return false
        true
        
    deduct: (cost) ->
        
        for stone in Stone.resources
            @stones[stone] -= cost[stone]
        @dirty = true
        
    add: (stone) ->
        
        oldStones = @stones[stone]
        @stones[stone] += 1
        if Math.floor(oldStones/10) != Math.floor(@stones[stone]/10)
            @dirty = true
    
    #  0000000   0000000  00000000  000   000  00000000  
    # 000       000       000       0000  000  000       
    # 0000000   000       0000000   000 0 000  0000000   
    #      000  000       000       000  0000  000       
    # 0000000    0000000  00000000  000   000  00000000  
    
    initScene: ->
                
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
            
            @meshes[stone]?.parent.remove @meshes[stone]
            if @stones[stone]
                bufg = @geomForCostRange stone, 0, @stones[stone]
                mesh = new THREE.Mesh bufg, Materials.cost[stone]
                @scene.add mesh
                @meshes[stone] = mesh
            
        super()
            
module.exports = Storage
