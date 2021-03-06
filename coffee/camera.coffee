###
 0000000   0000000   00     00  00000000  00000000    0000000 
000       000   000  000   000  000       000   000  000   000
000       000000000  000000000  0000000   0000000    000000000
000       000   000  000 0 000  000       000   000  000   000
 0000000  000   000  000   000  00000000  000   000  000   000
###

{ reduce } = require 'kxk'

class Camera extends THREE.PerspectiveCamera

    constructor: (opt) ->
        
        width  = opt.view.clientWidth
        height = opt.view.clientHeight
        
        super 70, width/height, 0.01, 300 # fov, aspect, near, far
        
        @size    = vec width, height 
        @elem    = opt.view
        @dist    = 10
        @maxDist = @far/4
        @minDist = 0.9
        @center  = vec 0, 0, 0
        @degree  = 60
        @rotate  = 0
        @wheelInert = 0
        @pivotX = 0
        @pivotY = 0
        @moveX = 0
        @moveY = 0
        @quat = quat()

        @elem.addEventListener 'mousewheel', @onMouseWheel
        @elem.addEventListener 'mousedown',  @onMouseDown
        @elem.addEventListener 'keypress',   @onKeyPress
        @elem.addEventListener 'keyrelease', @onKeyRelease
        @elem.addEventListener 'dblclick',   @onDblClick
        
        @update()

    getPosition: -> vec @position
    getDir:      -> quat(@quaternion).rotate Vector.minusZ
    getUp:       -> quat(@quaternion).rotate Vector.unitY
    getRight:    -> quat(@quaternion).rotate Vector.unitX

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
           
    startPivotLeft: ->
        
        @pivotX = 20
        @startPivot()
        
    startPivotRight: ->
        
        @pivotX = -20
        @startPivot()

    startPivotUp: ->
        
        @pivotY = -10
        @startPivot()
        
    startPivotDown: ->
        
        @pivotY = 10
        @startPivot()
        
    stopPivot: ->
        
        @pivoting = false
        @pivotX = 0
        @pivotY = 0
       
    startPivot: -> 
        
        if not @pivoting
            rts.animate @pivotCenter
            @pivoting = true
            
    pivotCenter: (deltaSeconds) =>
        
        return if not @pivoting

        @pivot @pivotX, @pivotY
        
        rts.animate @pivotCenter
        
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
                     
    focusOnPos: (v) ->
        
        @centerTarget = vec v
        @center = vec v
        @update()
         
    fadeToPos: (v) -> 
        
        @centerTarget = vec v
        @startFadeCenter()

    startFadeCenter: -> 
        
        if not @fading
            rts.animate @fadeCenter
            @fading = true
            
    fadeCenter: (deltaSeconds) =>
        
        return if not @fading
        
        @center.fade @centerTarget, deltaSeconds
        @update()
        
        if @center.dist(@centerTarget) > 0.00001
            rts.animate @fadeCenter
        else
            delete @fading

    # 00     00   0000000   000   000  00000000  
    # 000   000  000   000  000   000  000       
    # 000000000  000   000   000 000   0000000   
    # 000 0 000  000   000     000     000       
    # 000   000   0000000       0      00000000  
    
    moveFactor: -> @dist/2
    
    startMoveLeft: ->
        
        @moveX = -@moveFactor()
        @startMove()
        
    startMoveRight: ->
        
        @moveX = @moveFactor()
        @startMove()

    startMoveUp: ->
        
        @moveY = @moveFactor()
        @startMove()
        
    startMoveDown: ->
        
        @moveY = -@moveFactor()
        @startMove()
        
    stopMoving: ->
        
        @moving = false
        @moveX = 0
        @moveY = 0
       
    startMove: -> 
        
        @fading = false
        if not @moving
            rts.animate @moveCenter
            @moving = true
            
    moveCenter: (deltaSeconds) =>
        
        return if not @moving
        
        dir = vec()
        dir.add Vector.unitX.mul @moveX
        dir.add Vector.unitY.mul @moveY
        dir.scale deltaSeconds
        dir.applyQuaternion @quaternion
        
        @center.add dir
        @update()
        
        rts.animate @moveCenter
        
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
            
        @wheelInert += event.wheelDelta * (1+(@dist/@maxDist)*3) * 0.0001
        
        @startZoom()

    # 0000000   0000000    0000000   00     00  
    #    000   000   000  000   000  000   000  
    #   000    000   000  000   000  000000000  
    #  000     000   000  000   000  000 0 000  
    # 0000000   0000000    0000000   000   000  

    startZoomIn: ->
        
        @wheelInert = (1+(@dist/@maxDist)*3)*10
        @startZoom()
        
    startZoomOut: ->
        
        @wheelInert = -(1+(@dist/@maxDist)*3)*10
        @startZoom()
    
    startZoom: -> 
        
        if not @zooming
            rts.animate @inertZoom
            @zooming = true
            
    stopZoom: -> 
        
        @wheelInert = 0
        @zooming = false
    
    inertZoom: (deltaSeconds) =>

        @setDistFactor 1 - clamp -0.02, 0.02, @wheelInert
        @wheelInert = reduce @wheelInert, deltaSeconds*0.3
        
        if Math.abs(@wheelInert) > 0.00000001
            rts.animate @inertZoom
        else
            delete @zooming
            @wheelInert = 0
    
    setDistFactor: (factor) =>
        
        @dist = clamp @minDist, @maxDist, @dist*factor
        @update()
        
    setFov: (fov) -> @fov = Math.max(2.0, Math.min fov, 175.0)
    
    # 000   000  00000000   0000000     0000000   000000000  00000000  
    # 000   000  000   000  000   000  000   000     000     000       
    # 000   000  00000000   000   000  000000000     000     0000000   
    # 000   000  000        000   000  000   000     000     000       
    #  0000000   000        0000000    000   000     000     00000000  
    
    update: -> 
        
        @degree = clamp 0, 180, @degree
        
        @quat.reset()
        @quat.rotateAxisAngle Vector.unitZ, @rotate
        @quat.rotateAxisAngle Vector.unitX, @degree
        
        @position.copy @center.plus vec(0,0,@dist).applyQuaternion @quat
        @quaternion.copy @quat
        
        # log "camera:", @dist, @rotate, @degree

module.exports = Camera
