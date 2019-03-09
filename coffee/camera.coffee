###
 0000000   0000000   00     00  00000000  00000000    0000000 
000       000   000  000   000  000       000   000  000   000
000       000000000  000000000  0000000   0000000    000000000
000       000   000  000 0 000  000       000   000  000   000
 0000000  000   000  000   000  00000000  000   000  000   000
###

{ reduce } = require 'kxk'

Quaternion  = require './lib/quaternion'

class Camera extends THREE.PerspectiveCamera

    constructor: (opt) ->
        
        width  = opt.view.clientWidth
        height = opt.view.clientHeight
        
        super 70, width/height, 0.01, 300 # fov, aspect, near, far
        
        @size    = vec width, height 
        @elem    = opt.view
        # @dist    = @far/64
        @dist    = 10
        @maxDist = @far/4
        @minDist = 0.9
        @center  = vec 0, 0, 0
        @degree  = 60
        @rotate  = 0
        @wheelInert = 0

        @elem.addEventListener 'mousewheel', @onMouseWheel
        @elem.addEventListener 'mousedown',  @onMouseDown
        @elem.addEventListener 'keypress',   @onKeyPress
        @elem.addEventListener 'keyrelease', @onKeyRelease
        @elem.addEventListener 'dblclick',   @onDblClick
        
        @update()

    getPosition:  -> vec @position
    getDirection: -> quat(@quaternion).rotate Vector.minusZ
    getUp:        -> quat(@quaternion).rotate Vector.unitY

    del: =>
        
        @elem.removeEventListener  'keypress',   @onKeyPress
        @elem.removeEventListener  'keyrelease', @onKeyRelease
        @elem.removeEventListener  'mousewheel', @onMouseWheel
        @elem.removeEventListener  'mousedown',  @onMouseDown
        @elem.removeEventListener  'dblclick',   @onDblClick
        window.removeEventListener 'mouseup',    @onMouseUp
        window.removeEventListener 'mousemove',  @onMouseDrag 
        
    # 00     00   0000000   000   000   0000000  00000000  
    # 000   000  000   000  000   000  000       000       
    # 000000000  000   000  000   000  0000000   0000000   
    # 000 0 000  000   000  000   000       000  000       
    # 000   000   0000000    0000000   0000000   00000000  
    
    onMouseDown: (event) => 
        
        @downButtons = event.buttons
        @mouseMoved  = false
            
        @mouseX = event.clientX
        @mouseY = event.clientY
        
        @downPos = vec @mouseX, @mouseY
        
        window.addEventListener 'mousemove', @onMouseDrag
        window.addEventListener 'mouseup',   @onMouseUp
        
    onMouseUp: (event) => 

        window.removeEventListener 'mousemove', @onMouseDrag
        window.removeEventListener 'mouseup',   @onMouseUp
        
    onDblClick: (event) =>
        
    onMouseDrag: (event) =>

        x = event.clientX-@mouseX
        y = event.clientY-@mouseY
        
        @mouseX = event.clientX
        @mouseY = event.clientY
        
        if @downPos.dist(vec @mouseX, @mouseY) > 60
            @mouseMoved = true
        
        if event.buttons & 4
            s = @dist
            @pan x*2*s/@size.x, y*s/@size.y
            
        if event.buttons & 2
            @pivot 4000*x/@size.x, 2000*y/@size.y
            
    # 00000000   000  000   000   0000000   000000000  
    # 000   000  000  000   000  000   000     000     
    # 00000000   000   000 000   000   000     000     
    # 000        000     000     000   000     000     
    # 000        000      0       0000000      000     
    
    pivot: (x,y) ->
                
        @rotate += -0.1*x
        @degree += -0.1*y
        
        @update()
               
    # 00000000    0000000   000   000  
    # 000   000  000   000  0000  000  
    # 00000000   000000000  000 0 000  
    # 000        000   000  000  0000  
    # 000        000   000  000   000  
    
    pan: (x,y) ->
        
        right = vec -x, 0, 0 
        right.applyQuaternion @quaternion

        up = vec 0, y, 0 
        up.applyQuaternion @quaternion
        
        @center.add right.add up
        @centerTarget?.copy @center
        @update()
            
    # 00000000   0000000    0000000  000   000   0000000  
    # 000       000   000  000       000   000  000       
    # 000000    000   000  000       000   000  0000000   
    # 000       000   000  000       000   000       000  
    # 000        0000000    0000000   0000000   0000000   
         
    fadeToPos: (v) -> 
        
        @centerTarget = vec v
        @startFadeCenter()
            
    focusOnPos: (v) ->
        
        @centerTarget = vec v
        @center = vec v
        @update()
            
    startFadeCenter: -> 
        
        if not @fading
            rts.animate @fadeCenter
            @fading = true
            
    fadeCenter: (deltaSeconds) =>
        
        @center.fade @centerTarget, deltaSeconds
        @update()
        
        if @center.dist(@centerTarget) > 0.00001
            rts.animate @fadeCenter
        else
            delete @fading
            
    # 000   000  000   000  00000000  00000000  000      
    # 000 0 000  000   000  000       000       000      
    # 000000000  000000000  0000000   0000000   000      
    # 000   000  000   000  000       000       000      
    # 00     00  000   000  00000000  00000000  0000000  
    
    onMouseWheel: (event) => 
    
        if @wheelInert > 0 and event.wheelDelta < 0
            @wheelInert = 0
            return
            
        if @wheelInert < 0 and event.wheelDelta > 0
            @wheelInert = 0
            return
            
        @wheelInert += event.wheelDelta * (1+(@dist/@maxDist)*3) * 0.000005
        
        @startZoom()

    # 0000000   0000000    0000000   00     00  
    #    000   000   000  000   000  000   000  
    #   000    000   000  000   000  000000000  
    #  000     000   000  000   000  000 0 000  
    # 0000000   0000000    0000000   000   000  

    startZoom: -> 
        
        if not @zooming
            rts.animate @inertZoom
            @zoominging = true
    
    inertZoom: (deltaSeconds) =>

        @setDist 1 - clamp -0.005, 0.005, @wheelInert
        @wheelInert = reduce @wheelInert, deltaSeconds*0.003
        
        if Math.abs(@wheelInert) > 0.00000001
            rts.animate @inertZoom
        else
            delete @zooming
            @wheelInert = 0
    
    setDist: (factor) =>
        
        @dist = clamp @minDist, @maxDist, @dist*factor
        @update()
        
    setFov: (fov) -> @fov = Math.max(2.0, Math.min fov, 175.0)
    
    # 000   000  00000000   0000000     0000000   000000000  00000000  
    # 000   000  000   000  000   000  000   000     000     000       
    # 000   000  00000000   000   000  000000000     000     0000000   
    # 000   000  000        000   000  000   000     000     000       
    #  0000000   000        0000000    000   000     000     00000000  
    
    rotQuat: ->

        q = quat()
        q.multiply quat().setFromAxisAngle vec(0, 0, 1), deg2rad @rotate
        q.multiply quat().setFromAxisAngle vec(1, 0, 0), deg2rad @degree
        q
    
    update: -> 
        
        @degree = clamp 0, 180, @degree
        q = @rotQuat()
        @position.copy @center.plus vec(0,0,@dist).applyQuaternion q
        @quaternion.copy q

module.exports = Camera
