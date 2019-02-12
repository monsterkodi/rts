###
0000000    000   000  000   000 
000   000  000   000   000 000  
0000000    000   000    00000   
000   000  000   000     000    
0000000     0000000      000    
###

{ post, elem, log, _ } = require 'kxk'

{ Stone } = require '../constants'

CanvasButton = require './canvasbutton'
Materials    = require '../materials'

class BuyButton extends CanvasButton

    constructor: (botButton) ->
        
        div = botButton.canvas.parentElement
        
        super div, 'buyButton'
        
        @bot = botButton.bot
        
        y = botButton.canvas.offsetTop
        @canvas.style = "left:100px; top:#{y}px"
        
        @camera.updateProjectionMatrix()
        @render()
        
        post.on 'storageChanged', @onStorageChanged
        
        @canvas.addEventListener 'mouseout', @del
        
    del: ->
        
        @canvas.removeEventListener 'mouseout', @del        
        post.removeListener 'storageChanged', @onStorageChanged
        super()
        
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
        
        @camera.fov = 40
        @camera.position.copy vec(0,2,1).normal().mul 22
        @camera.lookAt vec 0,7.6,0
        
    highlight: -> 

        return if not @canAfford()
        
        @camera.fov = 33
        @camera.updateProjectionMatrix()
        @render()
    
    unhighlight: ->
        
        @camera.fov = 40
        @camera.updateProjectionMatrix()
        @render()
        
    click: -> 
        
        if @canAfford()
            rts.world.storage.deduct rts.market.costForBot @bot
            log 'build bot', @bot
            
    cost: -> rts.market.costForBot @bot
    canAfford: -> rts.world.storage.canAfford @cost()
        
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    onStorageChanged: => @render()
    
    render: ->

        cost = @cost()
        have = rts.world.storage.stones
        
        for stone in Stone.resources
            
            bufg = @geomForCostRange stone, 0, Math.min have[stone], cost[stone]
            mesh = new THREE.Mesh bufg, Materials.cost[stone]
            @scene.add mesh
            @meshes[stone]?.parent.remove @meshes[stone]
            @meshes[stone] = mesh
            
            @meshes[stone+4]?.parent.remove @meshes[stone+4]
            delete @meshes[stone+4]
            
            if cost[stone] > have[stone]
                bufg = @geomForCostRange stone, have[stone], cost[stone]
                mesh = new THREE.Mesh bufg, Materials.cost[4]
                @scene.add mesh
                @meshes[stone+4] = mesh
        
        super()
            
    geomForCostRange: (stone, from, to) ->
        
        merg = new THREE.Geometry 
        
        if from > 0
            
            l = Math.ceil from/100
            
            if Math.floor(from/10)%10 > 0
                for y in [((Math.floor(from/10))%10)...9]
                    geom = new THREE.BoxGeometry 0.5,0.5,0.5
                    geom.translate -0.25 + (y%2 and 0.5 or 0),((l-1)*1.2)+0.25+(y>4 and 0.5 or 0), -0.25 + (y%5>2 and 0.5 or 0)
                    merg.merge geom
            
        else
            l = Math.floor from/100
        
        h = Math.floor to/100
        
        for y in [l...h]
            geom = new THREE.BoxGeometry 1,1,1
            geom.translate 0,(y*1.2)+0.5,0
            merg.merge geom
                       
        for y in [0...(Math.floor(to/10))%10]
            break if y == 9
            geom = new THREE.BoxGeometry 0.5,0.5,0.5
            geom.translate -0.25 + (y%2 and 0.5 or 0),(h*1.2)+0.25+(y>4 and 0.5 or 0), -0.25 + (y%5>2 and 0.5 or 0)
            merg.merge geom
                
        merg.translate stone*1.5-2.3, 0, 0 
            
        new THREE.BufferGeometry().fromGeometry merg
                
module.exports = BuyButton
