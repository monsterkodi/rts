###
00000000   000000000   0000000
000   000     000     000     
0000000       000     0000000 
000   000     000          000
000   000     000     0000000 
###

{ prefs, post, randInt, clamp, elem, empty, valid, first, last, stopEvent, deg2rad, rad2deg, str, log, $, _ } = require 'kxk'

{ Bot, Stone, Geom, Face, Edge, Bend } = require './constants'

window.$         = $
window._         = _
window.post      = post
window.prefs     = prefs
window.randInt   = randInt
window.deg2rad   = deg2rad
window.rad2deg   = rad2deg
window.stopEvent = stopEvent
window.clamp     = clamp
window.empty     = empty
window.valid     = valid
window.first     = first
window.last      = last
window.elem      = elem
window.str       = str
window.log       = log

window.Bot       = Bot
window.Edge      = Edge
window.Bend      = Bend
window.Geom      = Geom
window.Face      = Face
window.Stone     = Stone
window.THREE     = require 'three'
window.Vector    = require './lib/vector'
window.Color     = require './color'
window.Science   = require './science'
window.Geometry  = require './geometry'
window.Materials = require './materials'
window.playSound = (o,n,c) -> rts.sound.play o,n,c

FPS     = require './lib/fps'
Info    = require './lib/info'
Debug   = require './lib/debug'
Sound   = require './lib/sound'
Config  = require './config'
Menu    = require './menu/menu'
World   = require './world'
Map     = require './map'
Camera  = require './camera'
Handle  = require './handle'

class RTS

    constructor: (@view) ->
        
        window.rts = @
        window.config  = Config.default
        
        @sound = new Sound
        
        @menuBorderWidth = 50
        
        @fps = new FPS
        @paused = false
        @animations = []
        @worldAnimations = []
        
        @renderer = new THREE.WebGLRenderer antialias: true
        @renderer.setPixelRatio window.devicePixelRatio

        @renderer.setClearColor Color.menu.background     
        @renderer.setSize @view.clientWidth, @view.clientHeight
        @renderer.shadowMap.enabled = true
        @renderer.shadowMap.type = THREE.PCFSoftShadowMap
        
        # log @renderer.capabilities
        
        @view.appendChild @renderer.domElement
        
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
        @light2.position.set 50, 0, 50
        @light2.target.position.set 0, 0, 1
        @light2.castShadow = true
        @light2.shadow.mapSize = shadowMapSize
        @scene.add @light2
        @scene.add @light2.target
        
        @ambient = new THREE.AmbientLight 0x333333
        @scene.add @ambient
        
        # @scene.add new THREE.CameraHelper @camera 
        # gridHelper = new THREE.GridHelper 100, 100, 0x444444, 0x111111
        # gridHelper.rotateX deg2rad 90
        # gridHelper.position.set 0, 0,-0.001
        # @scene.add gridHelper
        # @scene.add new THREE.AxesHelper 50
        
        # @scene.add new THREE.PointLightHelper @sun, 5
        # @scene.add new THREE.DirectionalLightHelper @light, 5
        # @light2Helper = new THREE.DirectionalLightHelper @light2, 5, new THREE.Color 0xffff00
        # @scene.add @light2Helper
        
        new Map @scene
        @handle = new Handle @world
                
        @mouse = vec()
        
        @raycaster = new THREE.Raycaster()
        
        document.addEventListener 'mousemove', @onMouseMove
        document.addEventListener 'mousedown', @onMouseDown
        document.addEventListener 'mouseup',   @onMouseUp
        document.addEventListener 'dblclick',  @onDblClick
        
        @menu = new Menu
        
        @lastAnimationTime = window.performance.now()
                
        @animationStep()

    #  0000000   000   000  000  00     00   0000000   000000000  00000000  
    # 000   000  0000  000  000  000   000  000   000     000     000       
    # 000000000  000 0 000  000  000000000  000000000     000     0000000   
    # 000   000  000  0000  000  000 0 000  000   000     000     000       
    # 000   000  000   000  000  000   000  000   000     000     00000000  
    
    animate: (func) ->
        
        @animations.push func
        
    animateWorld: (func) ->
        
        @worldAnimations.push func
        
    togglePause: -> 
    
        @paused = not @paused
        post.emit 'pause', @paused
    
    animationStep: =>
        
        now = window.performance.now()
        delta = (now - @lastAnimationTime) * 0.001
        @lastAnimationTime = now
        
        oldAnimations = @animations.clone()
        @animations = []
        for animation in oldAnimations
            animation delta
        
        if not @paused
            
            angle = -delta*0.01*@world.speed
            @light2.position.applyQuaternion quat().setFromAxisAngle vec(0, 0, 1), angle
            @light2Helper?.update()   
            @world.animate delta
            @menu.animate delta
            
            oldWorldAnimations = @worldAnimations.clone()
            @worldAnimations = []
            for animation in oldWorldAnimations
                animation delta * @world.speed
                    
        @render()
        setTimeout @animationStep, 1000/60
            
    # 00     00   0000000   000   000   0000000  00000000  
    # 000   000  000   000  000   000  000       000       
    # 000000000  000   000  000   000  0000000   0000000   
    # 000 0 000  000   000  000   000       000  000       
    # 000   000   0000000    0000000   0000000   00000000  
    
    onMouseDown: (event) =>
        
        @calcMouse event
        @downPos = @mouse.clone()
        
        if event.buttons == 1
                        
            if @world.highBot?
                @dragBot = @world.highBot
            else
                delete @dragBot
        else
            @camMove = true
            
        if event.button == 2
            if @rightUp and window.performance.now() - @rightUp < 500
                @handle.doubleRightClick()
            delete @rightUp
                
    onMouseUp: (event) =>

        if not @camMove
            delete @dragBot
                        
        delete @camMove
        
        @calcMouse event

        moved = @downPos?.dist @mouse
        if moved < 0.01
            if event.button == 1
                @focusOnHit()
            else
                if bot = @world.highBot
                    @handle.botClicked bot
                    
            if event.button == 2
                @rightUp = window.performance.now()
    
    onMouseMove: (event) =>

        @calcMouse event
        
        return if event.buttons > 1
        
        hit = @castRay event.buttons == 1
        
        if not @dragBot
                            
            @handle.mouseMoveHit hit
                
        else 
            moved = @downPos?.dist @mouse
            if moved < 0.01
                return
            
            if hit?.face?
                @handle.moveBot @dragBot, hit.pos, hit.face

    onDblClick: (event) => 
        # log 'doubleClick', event.target.button?
        if not event.target.button
            @handle.doubleClick()
                            
    calcMouse: (event) ->
        
        br = @view.getBoundingClientRect()
        
        @mouse.x = ((event.clientX-br.left) / br.width) * 2 - 1
        @mouse.y = -((event.clientY-br.top) / br.height ) * 2 + 1
        @mouse
        
    focusOnHit: ->
        
        if hit = @castRay false
            if hit.bot
                @camera.fadeToPos hit.bot.pos
            else    
                @camera.fadeToPos @world.roundPos hit.point.minus hit.norm.mul 0.5

    #  0000000   0000000    0000000  000000000  00000000    0000000   000   000  
    # 000       000   000  000          000     000   000  000   000   000 000   
    # 000       000000000  0000000      000     0000000    000000000    00000    
    # 000       000   000       000     000     000   000  000   000     000     
    #  0000000  000   000  0000000      000     000   000  000   000     000     
    
    filterHit: (intersects, ignoreHighlight) ->
        
        intersects = intersects.filter (i) => i.object.stone? or i.object.bot
        if ignoreHighlight
            intersects = intersects.filter (i) => i.object != @world.highBot?.mesh
            
        intersects[0]
    
    castRay: (ignoreHighlight) ->
        
        @raycaster.setFromCamera @mouse, @camera
        intersects = @raycaster.intersectObjects @scene.children, false

        # log intersects.length
        intersect = @filterHit intersects, ignoreHighlight
        
        return if empty intersect
        
        point = vec intersect.point
        
        info = 
            pos:    @world.roundPos point
            index:  @world.indexAtPos @world.roundPos point
            norm:   vec intersect.face.normal
            point:  point
            dist:   intersect.distance
            
        @scene.remove @cursor if @cursor
        delete @cursor
            
        if intersect.object.bot
            info.bot = @world.botAtPos point
        
        stones = intersects.filter (i) => i.object.stone?
        if valid stones
            info.face = @world.faceAtPosNorm stones[0].point, stones[0].face.normal
        
        info
        
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    render: ->

        @sun.position.copy @camera.position
        @renderer.render @world.scene, @camera
        
        @fps.draw()
        
        return if @paused

        if prefs.get 'info'
            @info = new Info if not @info
            @info.draw()
        else if @info?
            @info.del()
            delete @info
            
        if prefs.get 'debug'
            @debug = new Debug if not @debug
        else if @debug
            @debug.del()
            delete @debug

    # 00000000   00000000   0000000  000  0000000  00000000  0000000  
    # 000   000  000       000       000     000   000       000   000
    # 0000000    0000000   0000000   000    000    0000000   000   000
    # 000   000  000            000  000   000     000       000   000
    # 000   000  00000000  0000000   000  0000000  00000000  0000000  
    
    resized: (w,h) ->
        
        @camera.aspect = w/h
        @camera.size = vec w,h
        @camera.updateProjectionMatrix()
        @renderer.setSize w,h
        
module.exports = RTS
