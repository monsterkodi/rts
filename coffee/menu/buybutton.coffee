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

        if @canAfford()
            @renderActive @cost()
        else 
            @renderInactive @cost(), rts.world.storage.stones
            
        super()
            
    renderActive: (cost) ->
        
        pos = vec -2.3,0,0
        for stone in Stone.resources

            merg = new THREE.Geometry 
            
            h = Math.floor cost[stone]/100
            for y in [0...h]
                geom = new THREE.BoxGeometry 1,1,1
                geom.translate 0,(y*1.2)+0.5,0
                merg.merge geom
                
            for y in [0...Math.floor(cost[stone]/10)%10]
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
            
    geomForCostRange: (stone, from, to) ->
        
        merg = new THREE.Geometry 
        
        h = Math.floor Math.min(have[stone], cost[stone])/100
        for y in [0...h]
            geom = new THREE.BoxGeometry 1,1,1
            geom.translate 0,(y*1.2)+0.5,0
            merg.merge geom
                       
        if cost[stone] <= have[stone]
            for y in [0...Math.floor(Math.min(have[stone], cost[stone])/10)%10]
                break if y == 9
                geom = new THREE.BoxGeometry 0.5,0.5,0.5
                geom.translate -0.25 + (y%2 and 0.5 or 0),(h*1.2)+0.25+(y>4 and 0.5 or 0), -0.25 + (y%5>2 and 0.5 or 0)
                merg.merge geom
                
        merg.translate stone*1.5-2.3, 0, 0 
            
        new THREE.BufferGeometry().fromGeometry merg
        
    renderInactive: (cost, have) ->
        
        for stone in Stone.resources
            bufg = @geomForCostRange stone, 0, Math.min have[stone], cost[stone]
            
            mesh = new THREE.Mesh bufg, Materials.cost[stone]
            @scene.add mesh
            @meshes[stone]?.parent.remove @meshes[stone]
            @meshes[stone] = mesh
        
    renderInactiveOld: (cost, have) ->
        
        pos = vec -2.3,0,0
        for stone in Stone.resources

            merg = new THREE.Geometry 
            
            h = Math.floor Math.min(have[stone], cost[stone])/100
            for y in [0...h]
                geom = new THREE.BoxGeometry 1,1,1
                geom.translate 0,(y*1.2)+0.5,0
                merg.merge geom
                           
            if cost[stone] <= have[stone]
                for y in [0...Math.floor(Math.min(have[stone], cost[stone])/10)%10]
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
            
            if cost[stone] > have[stone]
                
                merg = new THREE.Geometry 
                
                l = h
                h = Math.floor(cost[stone])/100
                for y in [l...h]
                    geom = new THREE.BoxGeometry 1,1,1
                    geom.translate 0,(y*1.2)+0.5,0
                    merg.merge geom
                         
                for y in [0...Math.floor(cost[stone]/10)%10]
                    break if y == 9
                    geom = new THREE.BoxGeometry 0.5,0.5,0.5
                    geom.translate -0.25 + (y%2 and 0.5 or 0),(h*1.2)+0.25+(y>4 and 0.5 or 0), -0.25 + (y%5>2 and 0.5 or 0)
                    merg.merge geom
                    
                bufg = new THREE.BufferGeometry().fromGeometry merg
                mesh = new THREE.Mesh bufg, Materials.cost[4]
                mesh.position.copy pos
                @scene.add mesh
                @meshes[stone+4]?.parent.remove @meshes[stone+4]
                @meshes[stone+4] = mesh
                        
            pos.add vec 1.5, 0, 0
                
module.exports = BuyButton
