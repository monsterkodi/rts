###
0000000    000   000  000   000 
000   000  000   000   000 000  
0000000    000   000    00000   
000   000  000   000     000    
0000000     0000000      000    
###

{ elem, log, _ } = require 'kxk'

{ Stone } = require '../constants'

Materials = require '../materials'

class BuyButton

    constructor: (@botButton) ->
        
        @stones = [0,100,50,0,0]
        
        @width  = 100
        @height = 100
        
        @meshes = {}
        
        @initScene()
        @render()
        
        @canvas.addEventListener 'mouseout', @onMouseOut
        
    onMouseOut: => 
    
        @canvas.remove()
        
    #  0000000   0000000  00000000  000   000  00000000  
    # 000       000       000       0000  000  000       
    # 0000000   000       0000000   000 0 000  0000000   
    #      000  000       000       000  0000  000       
    # 0000000    0000000  00000000  000   000  00000000  
    
    initScene: ->
        
        y = @botButton.canvas.offsetTop
        @canvas = elem 'canvas', class:'buyButton', width:@width, height:@height, style:"left:100px; top:#{y}px"
        @botButton.canvas.parentElement.appendChild @canvas
        
        @renderer = new THREE.WebGLRenderer antialias:true, canvas:@canvas
        @renderer.setPixelRatio window.devicePixelRatio
        @renderer.setSize @width, @height
        
        @scene = new THREE.Scene()
        @scene.background = new THREE.Color 0x181818
        
        @light = new THREE.DirectionalLight 0xffffff
        @light.position.set 0,10,6
        @scene.add @light
        
        @scene.add new THREE.AmbientLight 0xffffff
        
        @camera = new THREE.PerspectiveCamera 30, @width/@height, 0.01, 1000
        @camera.position.copy vec(0,2,1).normal().mul 22
        @camera.lookAt vec 0,7.6,0
        
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    render: ->

        pos = vec -2.3,0,0
        for stone in Stone.resources

            merg = new THREE.Geometry 
            
            h = Math.floor @stones[stone]/100
            for y in [0...h]
                geom = new THREE.BoxGeometry 1,1,1
                geom.translate 0,(y*1.2)+0.5,0
                merg.merge geom
                
            log '----', @stones[stone], Math.floor(@stones[stone]/10), Math.floor(@stones[stone]/10)%10
            for y in [0...Math.floor(@stones[stone]/10)%10]
                break if y == 9
                geom = new THREE.BoxGeometry 0.5,0.5,0.5
                geom.translate -0.25 + (y%2 and 0.5 or 0),(h*1.2)+0.25+(y>4 and 0.5 or 0), -0.25 + (y%5>2 and 0.5 or 0)
                merg.merge geom
            
            bufg = new THREE.BufferGeometry().fromGeometry merg
            mesh = new THREE.Mesh bufg, Materials.stone[stone]
            mesh.position.copy pos
            @scene.add mesh
            
            @meshes[stone]?.parent.remove @meshes[stone]
            @meshes[stone] = mesh
                
            pos.add vec 1.5, 0, 0
                
        @renderer.render @scene, @camera

module.exports = BuyButton
