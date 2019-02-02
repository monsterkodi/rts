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

window.THREE = THREE
# require "three/examples/js/postprocessing/EffectComposer"
# require "three/examples/js/postprocessing/RenderPass"
# require "three/examples/js/postprocessing/ShaderPass"
# require "three/examples/js/postprocessing/SAOPass"
# require "three/examples/js/shaders/CopyShader"
# require "three/examples/js/shaders/SAOShader"
# require "three/examples/js/shaders/DepthLimitedBlurShader"
# require "three/examples/js/shaders/UnpackDepthRGBAShader"
# require "three/examples/js/postprocessing/SSAOPass"
# require "three/examples/js/shaders/SSAOShader"

class RTS

    constructor: (@view) ->
        
        @fps = new FPS
        
        @paused = false
        
        @renderer = new THREE.WebGLRenderer antialias: true

        @renderer.setClearColor 0x181818        
        @renderer.setSize @view.clientWidth, @view.clientHeight
        @renderer.shadowMap.enabled = true
        @renderer.shadowMap.type = THREE.PCFSoftShadowMap
        
        # log @renderer.capabilities
        
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
        
        @sun = new THREE.PointLight 0xffffff, 0.5
        @sun.position.copy @player.camera.getPosition() if @player?
        @sun.position.copy @camera.position
        @scene.add @sun

        shadowMapSize = new THREE.Vector2 2*2048, 2*2048
        
        @light = new THREE.DirectionalLight
        @light.intensity = 0.2
        @light.position.z = 100
        @light.castShadow = true
        @light.shadow.mapSize = shadowMapSize
        @scene.add @light

        @light2 = new THREE.PointLight
        @light2.intensity = 0.5
        @light2.position.z = 20
        @light2.position.x = 20
        @light2.castShadow = true
        @light2.shadow.mapSize = shadowMapSize
        @scene.add @light2
        
        @ambient = new THREE.AmbientLight 0x333333
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

        @light2.position.applyQuaternion new THREE.Quaternion().setFromAxisAngle new THREE.Vector3(0, 0, 1), -step.dsecs*0.03
        
        # @camera.pivot step.dsecs*2, step.dsecs*1
            
    render: ->
            
        @sun.position.copy @camera.position
        @renderer.render @world.scene, @camera
        # @composer.render()

    # 00000000   00000000   0000000  000  0000000  00000000  0000000  
    # 000   000  000       000       000     000   000       000   000
    # 0000000    0000000   0000000   000    000    0000000   000   000
    # 000   000  000            000  000   000     000       000   000
    # 000   000  00000000  0000000   000  0000000  00000000  0000000  
    
    resized: (w,h) ->
        
        @camera.aspect = w/h
        @camera.updateProjectionMatrix()
        @renderer.setSize w,h
        @ssaoPass?.setSize w,h
        
module.exports = RTS
