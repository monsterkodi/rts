###
00000000   000000000   0000000
000   000     000     000     
0000000       000     0000000 
000   000     000          000
000   000     000     0000000 
###

{ elem, deg2rad, log, _ } = require 'kxk'

FPS    = require './lib/fps'
Info   = require './lib/info'
World  = require './world'
Camera = require './camera'
THREE  = require 'three'

window.THREE = THREE

class RTS

    constructor: (@view) ->
        
        window.rts = @
        @fps = new FPS
        @info = new Info
        
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

        @light2 = new THREE.DirectionalLight
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
        
        document.addEventListener 'mousemove', @onMouseMove
        document.addEventListener 'mousedown', @onMouseDown
        document.addEventListener 'mouseup',   @onMouseUp
        
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
            angle = -deltaSeconds*0.3
            @light2.position.applyQuaternion new THREE.Quaternion().setFromAxisAngle new THREE.Vector3(0, 0, 1), angle
        
        oldAnimations = @animations.clone()
        @animations = []
        
        for animation in oldAnimations
            animation deltaSeconds
            
        @render()
        setTimeout @animationStep, 1000/60
            
    # 00     00   0000000   000   000   0000000  00000000  
    # 000   000  000   000  000   000  000       000       
    # 000000000  000   000  000   000  0000000   0000000   
    # 000 0 000  000   000  000   000       000  000       
    # 000   000   0000000    0000000   0000000   00000000  
    
    onMouseDown: (event) =>
        
        if event.buttons & 1
            
            @castRay @calcMouse event
            
            if @world.highlightIndex?
                @dragBot = 
                    index: @world.highlightIndex
                    pos:   @world.posAtIndex @world.highlightIndex
                    bot:   @world.botAtPos @world.posAtIndex @world.highlightIndex
            else
                delete @dragBot
        
    onMouseUp: (event) =>

        delete @dragBot
        @calcMouse event
    
    onMouseMove: (event) =>
        
        hit = @castRay @calcMouse event

        if hit and @dragBot
            if not hit.bot and not @dragBot.pos.equals hit.pos
                # log 'bot move', @dragBot, hit
                @world.moveBot @dragBot.pos, hit.pos 
                @dragBot.index = @world.toIndex hit.pos
                @dragBot.pos = hit.pos
        
    calcMouse: (event) ->
        
        br = @elem.getBoundingClientRect()
        @mouse.x = ((event.clientX-br.left) / br.width) * 2 - 1
        @mouse.y = -((event.clientY-br.top) / br.height ) * 2 + 1
        return @mouse

    #  0000000   0000000    0000000  000000000  00000000    0000000   000   000  
    # 000       000   000  000          000     000   000  000   000   000 000   
    # 000       000000000  0000000      000     0000000    000000000    00000    
    # 000       000   000       000     000     000   000  000   000     000     
    #  0000000  000   000  0000000      000     000   000  000   000     000     
    
    castRay: (screenPos) ->
        
        @raycaster.setFromCamera screenPos, @camera
        intersects = @raycaster.intersectObjects @scene.children, true

        if intersects.length
            # log intersects[0].distance, intersects[0].point, intersects[0].face
            
            point = intersects[0].point
            @world.highlightPos point     
            
            return 
                norm: intersects[0].face.normal
                dist: intersects[0].distance
                bot: @world.botAtPos point
                pos: @world.roundPos point
            
            # @scene.remove @cursor if @cursor
#             
            # if intersects[0].face and not @world.highlightIndex
#                 
                # geom = new THREE.CircleGeometry 0.1, 18
                # geom.translate 0,0,0.01
                # wire = new THREE.WireframeGeometry geom
                # @cursor = new THREE.LineSegments wire, new THREE.LineBasicMaterial color:0xfff000
                # @cursor.quaternion.copy new THREE.Quaternion().setFromUnitVectors new THREE.Vector3(0,0,1), intersects[0].face.normal
                # @cursor.position.copy intersects[0].point
                # @scene.add @cursor
        
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    render: ->

        @sun.position.copy @camera.position
        @renderer.render @world.scene, @camera
        
        @fps.draw()
        @info.draw @renderer.info

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
