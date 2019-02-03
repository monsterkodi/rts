###
 0000000   0000000   00     00  00000000  00000000    0000000 
000       000   000  000   000  000       000   000  000   000
000       000000000  000000000  0000000   0000000    000000000
000       000   000  000 0 000  000       000   000  000   000
 0000000  000   000  000   000  00000000  000   000  000   000
###

{ deg2rad, clamp, reduce, log } = require 'kxk'

Vector      = require './lib/vector'
Quaternion  = require './lib/quaternion'
THREE       = require 'three'

class Camera extends THREE.PerspectiveCamera

    constructor: (opt) ->
        
        aspect = opt.view.clientWidth / opt.view.clientHeight
        super 70, aspect, 0.01, 300 # fov, aspect, near, far
        
        @elem    = opt.view
        @dist    = @far/16
        @maxDist = @far/2
        @minDist = 0.4
        @center  = new Vector 0, 0, 0
        @degree  = 40
        @rotate  = 40
        @wheelInert = 0
        @rotateInert = 0
        @degreeInert = 0

        @elem.addEventListener 'mousewheel', @onMouseWheel
        @elem.addEventListener 'mousedown',  @onMouseDown
        @elem.addEventListener 'keypress',   @onKeyPress
        @elem.addEventListener 'keyrelease', @onKeyRelease
        
        @update()

    getPosition:  -> new Vector @position
    getDirection: -> new Quaternion(@quaternion).rotate Vector.minusZ
    getUp:        -> new Quaternion(@quaternion).rotate Vector.unitY

    del: =>
        
        @elem.removeEventListener  'keypress',   @onKeyPress
        @elem.removeEventListener  'keyrelease', @onKeyRelease
        @elem.removeEventListener  'mousewheel', @onMouseWheel
        @elem.removeEventListener  'mousedown',  @onMouseDown
        window.removeEventListener 'mouseup',    @onMouseUp
        window.removeEventListener 'mousemove',  @onMouseDrag 
        
    # 00     00   0000000   000   000   0000000  00000000  
    # 000   000  000   000  000   000  000       000       
    # 000000000  000   000  000   000  0000000   0000000   
    # 000 0 000  000   000  000   000       000  000       
    # 000   000   0000000    0000000   0000000   00000000  
    
    onMouseDown: (event) => 
        
        if event.buttons == 1
            @focusOnHit()
            return
            
        @mouseX = event.clientX
        @mouseY = event.clientY
        window.addEventListener    'mousemove',  @onMouseDrag
        window.addEventListener    'mouseup',    @onMouseUp
        
    onMouseUp: (event) => 
        
        window.removeEventListener 'mousemove',  @onMouseDrag
        window.removeEventListener 'mouseup',    @onMouseUp
        
    onMouseDrag:  (event) =>

        x = @mouseX-event.clientX
        y = @mouseY-event.clientY
        @mouseX = event.clientX
        @mouseY = event.clientY
        
        if event.buttons & 4
            s = @dist * 0.001
            @pan x*s, y*s
            
        if event.buttons & 2
            @pivot x*0.001, y*0.001
            
    # 00000000   000  000   000   0000000   000000000  
    # 000   000  000  000   000  000   000     000     
    # 00000000   000   000 000   000   000     000     
    # 000        000     000     000   000     000     
    # 000        000      0       0000000      000     
    
    pivot: (x,y) ->
        
        if @rotateInert > 0 and x < 0 or @rotateInert < 0 and x > 0
            @rotateInert = 0
            
        if @degreeInert > 0 and y < 0 or @degreeInert < 0 and y > 0
            @degreeInert = 0
            return
        
        @rotateInert += x
        @degreeInert += y
        
        rts.animate @inertPivot
        
    inertPivot: (deltaSeconds) =>
        
        @rotate += clamp -0.1, 0.1, @rotateInert
        @degree += clamp -0.1, 0.1, @degreeInert
        @update()
        @rotateInert = reduce @rotateInert, deltaSeconds*0.02
        @degreeInert = reduce @degreeInert, deltaSeconds*0.02
        if Math.abs(@rotateInert) > 0.0001 or Math.abs(@degreeInert) > 0.0001
            rts.animate @inertPivot
        else
            @rotateInert = 0
            @degreeInert = 0
        
    # 00000000    0000000   000   000  
    # 000   000  000   000  0000  000  
    # 00000000   000000000  000 0 000  
    # 000        000   000  000  0000  
    # 000        000   000  000   000  
    
    pan: (x,y) ->
        
        right = new THREE.Vector3 x, 0, 0 
        right.applyQuaternion @quaternion

        up = new THREE.Vector3 0, -y, 0 
        up.applyQuaternion @quaternion
        
        if not @centerTarget
            @centerTarget = new Vector @center
            
        @centerTarget.add right.add up
        @startFadeCenter()
            
    # 00000000   0000000    0000000  000   000   0000000  
    # 000       000   000  000       000   000  000       
    # 000000    000   000  000       000   000  0000000   
    # 000       000   000  000       000   000       000  
    # 000        0000000    0000000   0000000   0000000   
    
    focusOnHit: ->
        
        raycaster = new THREE.Raycaster
        raycaster.setFromCamera rts.mouse, @
        intersects = raycaster.intersectObjects rts.scene.children, true

        if intersects.length
            @centerTarget = new Vector(intersects[0].point).round()
            @startFadeCenter()
            
    # 00000000   0000000   0000000    00000000       0000000  00000000  000   000  000000000  00000000  00000000   
    # 000       000   000  000   000  000           000       000       0000  000     000     000       000   000  
    # 000000    000000000  000   000  0000000       000       0000000   000 0 000     000     0000000   0000000    
    # 000       000   000  000   000  000           000       000       000  0000     000     000       000   000  
    # 000       000   000  0000000    00000000       0000000  00000000  000   000     000     00000000  000   000  
    
    startFadeCenter: -> rts.animate @fadeCenter
            
    fadeCenter: (deltaSeconds) =>
        
        @center.fade @centerTarget, deltaSeconds
        @update()
        if @center.distSquare(@centerTarget) > 0.001
            rts.animate @fadeCenter
            
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
        
        rts.animate @inertZoom

    # 0000000   0000000    0000000   00     00  
    #    000   000   000  000   000  000   000  
    #   000    000   000  000   000  000000000  
    #  000     000   000  000   000  000 0 000  
    # 0000000   0000000    0000000   000   000  
    
    inertZoom: (deltaSeconds) =>

        @setDist 1 - clamp -0.005, 0.005, @wheelInert
        @wheelInert = reduce @wheelInert, deltaSeconds*0.003*(1+(@dist/@maxDist)*3)
        if Math.abs(@wheelInert) > 0.00000001
            rts.animate @inertZoom
        else
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
    
    update: -> 
        
        @degree = clamp 0, 180, @degree
        q = new THREE.Quaternion()
        q.multiply new THREE.Quaternion().setFromAxisAngle new THREE.Vector3(0, 0, 1), deg2rad @rotate
        q.multiply new THREE.Quaternion().setFromAxisAngle new THREE.Vector3(1, 0, 0), deg2rad @degree
        @position.copy @center.plus new THREE.Vector3(0,0,@dist).applyQuaternion q
        @quaternion.copy q

module.exports = Camera
