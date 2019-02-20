###
00000000   000000000   0000000
000   000     000     000     
0000000       000     0000000 
000   000     000          000
000   000     000     0000000 
###

{ prefs, elem, empty, valid, deg2rad, log, _ } = require 'kxk'

{ Bot } = require './constants'

THREE   = require 'three'
FPS     = require './lib/fps'
Info    = require './lib/info'
Debug   = require './lib/debug'
Menu    = require './menu/menu'
World   = require './world'
Map     = require './map'
Color   = require './color'
Camera  = require './camera'
Handle  = require './handle'
Science = require './science'
Vector  = require './lib/vector'

window.THREE = THREE

class RTS

    constructor: (@view) ->
        
        window.rts = @
        
        @menuBorderWidth = 50
        
        @fps = new FPS
        @paused = false
        @animations = []
        
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
            
        @world  = new Map @scene    
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
    
    animationStep: =>
        
        now = window.performance.now()
        delta = (now - @lastAnimationTime) * 0.001
        @lastAnimationTime = now
        
        oldAnimations = @animations.clone()
        @animations = []
        
        for animation in oldAnimations
            animation delta
        
        if not @paused
            angle = -delta*0.3*@world.speed
            @light2.position.applyQuaternion quat().setFromAxisAngle vec(0, 0, 1), angle
                        
            @world.animate delta
                    
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
            moved = @downPos?.dist @mouse
            if moved < 0.01
                return
            
            if hit?.face? 
                @handle.moveBot @dragBot, hit.pos, hit.face

    onDblClick: (event) =>
        
        if bot = @world.highBot
            log 'double', Bot.string(bot.type), @world.stringForFaceIndex @world.faceIndexForBot bot
            switch bot.type
                when Bot.brain then state.brain.state = state.brain.state == 'on' and 'off' or 'on'
                when Bot.trade then state.trade.state = state.trade.state == 'on' and 'off' or 'on'
                    
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
