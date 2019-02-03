###
00000000   000000000   0000000
000   000     000     000     
0000000       000     0000000 
000   000     000          000
000   000     000     0000000 
###

{ elem, deg2rad, log, _ } = require 'kxk'

FPS    = require './lib/fps'
World  = require './world'
Camera = require './camera'
THREE  = require 'three'

window.THREE = THREE

class RTS

    constructor: (@view) ->
        
        window.rts = @
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
        
        @mouse = new THREE.Vector2
        @raycaster = new THREE.Raycaster()
        document.addEventListener 'mousemove', @onMouseMove, false
        
        @animations = []
        @lastAnimationTime = window.performance.now()
        @animationStep()

    #  0000000   000   000  000  00     00   0000000   000000000  00000000  
    # 000   000  0000  000  000  000   000  000   000     000     000       
    # 000000000  000 0 000  000  000000000  000000000     000     0000000   
    # 000   000  000  0000  000  000 0 000  000   000     000     000       
    # 000   000  000   000  000  000   000  000   000     000     00000000  
    
    animate: (func) ->
        
        @animations.push func
    
    animationStep: =>
        
        now = window.performance.now()
        deltaSeconds = (now - @lastAnimationTime) * 0.001
        @lastAnimationTime = now
        
        if not @paused
            @light2.position.applyQuaternion new THREE.Quaternion().setFromAxisAngle new THREE.Vector3(0, 0, 1), -deltaSeconds*0.003
        
        oldAnimations = @animations.clone()
        @animations = []
        
        for animation in oldAnimations
            animation deltaSeconds
            
        @render()
        setTimeout @animationStep, 1000/60
            
    onMouseMove: (event) =>
        
        br = @elem.getBoundingClientRect()
        @mouse.x = ((event.clientX-br.left) / br.width) * 2 - 1
        @mouse.y = -((event.clientY-br.top) / br.height ) * 2 + 1
        
    render: ->
            
        @raycaster.setFromCamera @mouse, @camera
        intersects = @raycaster.intersectObjects @scene.children, true

        if intersects.length
            geom = new THREE.CircleGeometry 0.1, 18
            geom.translate 0,0,0.01
            wire = new THREE.WireframeGeometry geom
            cone = new THREE.LineSegments wire, new THREE.LineBasicMaterial color:0xfff000
            cone.quaternion.copy new THREE.Quaternion().setFromUnitVectors new THREE.Vector3(0,0,1), intersects[0].face.normal
            cone.position.copy intersects[0].point
            @scene.add cone
            
        @sun.position.copy @camera.position
        @renderer.render @world.scene, @camera
        
        @scene.remove cone if cone
        
        @fps.draw()

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
