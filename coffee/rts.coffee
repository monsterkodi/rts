###
00000000   000000000   0000000
000   000     000     000     
0000000       000     0000000 
000   000     000          000
000   000     000     0000000 
###

{ elem, log, _ } = require 'kxk'

FPS    = require './lib/fps'
World  = require './world'
Camera = require './camera'
THREE  = require 'three'

class RTS

    constructor: (@view) ->
        
        @fps = new FPS
        
        @paused = false
        
        @renderer = new THREE.WebGLRenderer 
            antialias:              true
            autoClear:              true
            logarithmicDepthBuffer: false

        @renderer.setClearColor 0x181818        
        @renderer.setSize @view.clientWidth, @view.clientHeight
        @renderer.shadowMap.type = THREE.PCFSoftShadowMap
        
        @elem = document.createElement 'div'
        @elem.style.position = 'absolute'
        @elem.style.top = '0'
        @elem.style.left = '0'
        @elem.style.right = '0'
        @elem.style.bottom = '0'
        @elem.style.background = "#004"
        
        @view.appendChild @elem
        @elem.appendChild @renderer.domElement
        
        @camera = new Camera view:@view
        
        @scene = new THREE.Scene()
        
        @sun = new THREE.PointLight 0xffffff
        @sun.position.copy @player.camera.getPosition() if @player?
        @sun.position.copy @camera.position
        @scene.add @sun
        
        @ambient = new THREE.AmbientLight 0x111111
        @scene.add @ambient
            
        @world = new World @scene        
        
        @animate()

    #  0000000   000   000  000  00     00   0000000   000000000  00000000  
    # 000   000  0000  000  000  000   000  000   000     000     000       
    # 000000000  000 0 000  000  000000000  000000000     000     0000000   
    # 000   000  000  0000  000  000 0 000  000   000     000     000       
    # 000   000  000   000  000  000   000  000   000     000     00000000  
    
    animate: =>
        
        requestAnimationFrame @animate
        if not @paused
            secs = 1.0/60.0
            @animationStep delta: secs*1000, dsecs: secs
        @render()
            
    animationStep: (step) ->

        # if not @camera.isPivoting
            # @camera.pivot step.dsecs*0.2, step.dsecs*0.1
            
    render: ->
            
        @sun.position.copy @camera.position
        @renderer.render @world.scene, @camera

    # 00000000   00000000   0000000  000  0000000  00000000  0000000  
    # 000   000  000       000       000     000   000       000   000
    # 0000000    0000000   0000000   000    000    0000000   000   000
    # 000   000  000            000  000   000     000       000   000
    # 000   000  00000000  0000000   000  0000000  00000000  0000000  
    
    resized: (w,h) ->
        
        @camera.aspect = w/h
        @camera.updateProjectionMatrix()
        @renderer.setSize w,h
        
module.exports = RTS
