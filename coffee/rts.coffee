###
00000000   000000000   0000000
000   000     000     000     
0000000       000     0000000 
000   000     000          000
000   000     000     0000000 
###

{ elem, empty, valid, deg2rad, log, _ } = require 'kxk'

FPS    = require './lib/fps'
Info   = require './lib/info'
World  = require './world'
Camera = require './camera'
Vector = require './lib/vector'
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
            
            if @world.highlightBot?
                @dragBot = @world.highlightBot
            else
                delete @dragBot
        
    onMouseUp: (event) =>

        delete @dragBot
        @calcMouse event
    
    onMouseMove: (event) =>

        hit = @castRay @calcMouse event
        
        if not @dragBot
            if hit
                @world.highlightPos hit.pos
            return

        if hit?.face? and not hit.bot
            if @dragBot.face != hit.face or @dragBot.index != hit.index
                @world.moveBot @dragBot, hit.pos, hit.face
                @world.highlightPos @dragBot.pos

                # log @world.astar.findPath @world.indexAtPos(0,0,1), @world.indexAtPos(0,3,1)
                
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
    
    filterHit: (intersects) ->
        
        intersects = intersects.filter (i) -> valid i.face
        intersects = intersects.filter (i) => i.object != @world.highlightBot?.highlight
        intersects = intersects.filter (i) => i.object != @world.highlightBot?.mesh
        intersects[0]
    
    castRay: (screenPos) ->
        
        @raycaster.setFromCamera screenPos, @camera
        intersects = @raycaster.intersectObjects @scene.children, false 
        # log 'hits', intersects.length

        hit = @filterHit intersects

        return if empty hit
        
        point = hit.point
        # @world.highlightPos point     
        
        info = 
            pos:    @world.roundPos point
            index:  @world.indexAtPos @world.roundPos point
            norm:   hit.face.normal
            dist:   hit.distance
            
        @scene.remove @cursor if @cursor
        delete @cursor
            
        if bot = @world.botAtPos point
            if bot != @world.highlightBot
                info.bot = bot
                return info

        info.face = @world.faceAtPosNorm point, hit.face.normal
        
        # if hit.face and not @world.highlightBot
        #   geom = new THREE.CircleGeometry 0.1, 18
        #   geom.translate 0,0,0.01
        #   wire = new THREE.WireframeGeometry geom
        #   @cursor = new THREE.LineSegments wire, new THREE.LineBasicMaterial color:0xfff000
        #   @cursor.quaternion.copy new THREE.Quaternion().setFromUnitVectors new THREE.Vector3(0,0,1), hit.face.normal
        #   @cursor.position.copy hit.point
        
        if info.face < 6
            # geom = new THREE.ConeGeometry 0.5, 0.8
            # geom.rotateX deg2rad 90
            # wire = new THREE.WireframeGeometry geom
            # @cursor = new THREE.LineSegments wire, new THREE.LineBasicMaterial color:0xfff000
            # @cursor.name = 'cursor'
            # @cursor.quaternion.copy new THREE.Quaternion().setFromUnitVectors new THREE.Vector3(0,0,1), Vector.normals[info.face]
            # @cursor.position.copy info.pos
#                     
            # @scene.add @cursor
        else
            log 'DAFUK?', info.face
        
        # log info
            
        return info
        
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
