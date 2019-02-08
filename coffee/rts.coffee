###
00000000   000000000   0000000
000   000     000     000     
0000000       000     0000000 
000   000     000          000
000   000     000     0000000 
###

{ elem, empty, valid, deg2rad, log, _ } = require 'kxk'

THREE  = require 'three'
FPS    = require './lib/fps'
Info   = require './lib/info'
World  = require './world'
Map    = require './map'
Camera = require './camera'
Vector = require './lib/vector'

window.THREE = THREE

class RTS

    constructor: (@view) ->
        
        window.rts = @
        @fps = new FPS
        @info = new Info
        @paused = false
        @animations = []
        
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
        
        # @scene.add new THREE.CameraHelper @camera 
        
        # gridHelper = new THREE.GridHelper 100, 100, 0x444444, 0x111111
        # gridHelper.rotateX deg2rad 90
        # gridHelper.position.set 0, 0,-0.001
        # @scene.add gridHelper
        # @scene.add new THREE.AxesHelper 50
        
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
            
        # @world = new World @scene    
        @world = new Map @scene    
        
        @mouse = new THREE.Vector2
        @raycaster = new THREE.Raycaster()
        
        document.addEventListener 'mousemove', @onMouseMove
        document.addEventListener 'mousedown', @onMouseDown
        document.addEventListener 'mouseup',   @onMouseUp
        
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
        delta = (now - @lastAnimationTime) * 0.001
        @lastAnimationTime = now
        
        if not @paused
            angle = -delta*0.3
            @light2.position.applyQuaternion quat().setFromAxisAngle vec(0, 0, 1), angle
        
        oldAnimations = @animations.clone()
        @animations = []
        
        for animation in oldAnimations
            animation delta
            
        @world.animate delta
            
        @render()
        setTimeout @animationStep, 1000/60
            
    # 00     00   0000000   000   000   0000000  00000000  
    # 000   000  000   000  000   000  000       000       
    # 000000000  000   000  000   000  0000000   0000000   
    # 000 0 000  000   000  000   000       000  000       
    # 000   000   0000000    0000000   0000000   00000000  
    
    onMouseDown: (event) =>
        
        if event.buttons == 1
            
            @calcMouse event
            
            if @world.highlightBot?
                @dragBot = @world.highlightBot
            else
                delete @dragBot
                
        else
            @camMove = true
        
    onMouseUp: (event) =>

        if not @camMove
            delete @dragBot
        delete @camMove
            
        @calcMouse event
    
    onMouseMove: (event) =>

        @calcMouse event
        
        return if event.buttons > 1
        
        hit = @castRay event.buttons == 1
        
        if not @dragBot
            
            if hit and hit.bot?
                @world.highlightPos hit.pos
            else
                @world.removeHighlight()
                
        else 
            if hit?.face? and (not @world.botAtPos(hit.pos) or @world.botAtPos(hit.pos) == @dragBot)
                if @dragBot.face != hit.face or @dragBot.index != hit.index
                    @world.moveBot @dragBot, hit.pos, hit.face
                    @world.highlightPos @dragBot.pos

    calcMouse: (event) ->
        
        br = @elem.getBoundingClientRect()
        @mouse.x = ((event.clientX-br.left) / br.width) * 2 - 1
        @mouse.y = -((event.clientY-br.top) / br.height ) * 2 + 1
        @mouse

    #  0000000   0000000    0000000  000000000  00000000    0000000   000   000  
    # 000       000   000  000          000     000   000  000   000   000 000   
    # 000       000000000  0000000      000     0000000    000000000    00000    
    # 000       000   000       000     000     000   000  000   000     000     
    #  0000000  000   000  0000000      000     000   000  000   000     000     
    
    filterHit: (intersects, ignoreHighlight) ->
        
        intersects = intersects.filter (i) => i.object.stone? or i.object.bot
        if ignoreHighlight
            intersects = intersects.filter (i) => i.object != @world.highlightBot?.mesh
            
        intersects[0]
    
    castRay: (ignoreHighlight) ->
        
        @raycaster.setFromCamera @mouse, @camera
        intersects = @raycaster.intersectObjects @scene.children, false 
        # log 'hits', intersects.length

        intersect = @filterHit intersects, ignoreHighlight

        return if empty intersect
        
        point = intersect.point
        
        info = 
            pos:    @world.roundPos point
            index:  @world.indexAtPos @world.roundPos point
            norm:   intersect.face.normal
            dist:   intersect.distance
            
        @scene.remove @cursor if @cursor
        delete @cursor
            
        if intersect.object.bot
            info.bot = @world.botAtPos point
        
        stones = intersects.filter (i) => i.object.stone?
        if valid stones
            info.face = @world.faceAtPosNorm stones[0].point, stones[0].face.normal
        
        # if info.face < 6
            # geom = new THREE.ConeGeometry 0.5, 0.8
            # geom.rotateX deg2rad 90
            # wire = new THREE.WireframeGeometry geom
            # @cursor = new THREE.LineSegments wire, new THREE.LineBasicMaterial color:0xfff000
            # @cursor.name = 'cursor'
            # @cursor.quaternion.copy quat().setFromUnitVectors vec(0,0,1), Vector.normals[info.face]
            # @cursor.position.copy info.pos
            # @scene.add @cursor
        
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
        
module.exports = RTS
