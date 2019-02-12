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
        
        @stones    = [800,800,300,400]
        @temp      = [0,0,0,0]
        @maxStones = 1000
              
        @camera.updateProjectionMatrix()    
        @render()
                
    canTake: (stone) -> 
        
        return false if stone == Stone.gray
        if @stones[stone] + @temp[stone] < @maxStones
            @temp[stone] += 1
            return true
        false
        
    canBuild: -> 
        
        if @stones[Stone.white] >= 20
            @stones[Stone.white] -= 20
            @render()
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
        @render()
        
    add: (stone) ->
        
        oldStones = @stones[stone]
        @stones[stone] += 1
        if Math.floor(oldStones)/10 != Math.floor(@stones[stone])
            post.emit 'storageChanged'
            @render()
    
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

        pos = vec -2.3, 0, 0
        for stone in Stone.resources

            merg = new THREE.Geometry 
            
            h = Math.floor @stones[stone]/100
            for y in [0...h]
                geom = new THREE.BoxGeometry 1,1,1
                geom.translate 0,(y*1.2)+0.5,0
                merg.merge geom
                
            for y in [0...Math.floor(@stones[stone]/10)%10]
                break if y == 9
                geom = new THREE.BoxGeometry 0.5,0.5,0.5
                geom.translate -0.25 + (y%2 and 0.5 or 0),(h*1.2)+0.25+(y>4 and 0.5 or 0), -0.25 + (y%5>2 and 0.5 or 0)
                merg.merge geom
            
            bufg = new THREE.BufferGeometry().fromGeometry merg
            mesh = new THREE.Mesh bufg, Materials.cost[stone]
            mesh.position.copy pos
            @scene.add mesh
            
            @meshes[stone]?.parent.remove @meshes[stone]
            @meshes[stone] = mesh
                
            pos.add vec 1.5, 0, 0
            
        super()
            
module.exports = Storage
