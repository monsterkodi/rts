###
 0000000   0000000   00     00  00000000  00000000    0000000 
000       000   000  000   000  000       000   000  000   000
000       000000000  000000000  0000000   0000000    000000000
000       000   000  000 0 000  000       000   000  000   000
 0000000  000   000  000   000  00000000  000   000  000   000
###

{ deg2rad, rad2deg, clamp, valid, reduce, log } = require 'kxk'

Vector      = require './lib/vector'
Quaternion  = require './lib/quaternion'
THREE       = require 'three'

class Camera extends THREE.PerspectiveCamera

    constructor: (opt) ->
        
        aspect = opt.view.clientWidth / opt.view.clientHeight
        super 70, aspect, 0.01, 300 # fov, aspect, near, far
        
        @elem    = opt.view
        @dist    = @far/64
        @maxDist = @far/2
        @minDist = 0.4
        @center  = new Vector 0, 0, 0
        @degree  = 0
        @rotate  = 0
        @wheelInert = 0

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
        
        @downButtons = event.buttons
        @mouseMoved  = false
            
        @mouseX = event.clientX
        @mouseY = event.clientY
        
        @downPos = new Vector @mouseX, @mouseY
        
        window.addEventListener 'mousemove', @onMouseDrag
        window.addEventListener 'mouseup',   @onMouseUp
        
    onMouseUp: (event) => 

        if @downButtons & 1 or @downButtons & 4
            if not @mouseMoved
                @focusOnHit()
        
        window.removeEventListener 'mousemove', @onMouseDrag
        window.removeEventListener 'mouseup',   @onMouseUp
        
    onMouseDrag: (event) =>

        x = event.clientX-@mouseX
        y = event.clientY-@mouseY
        
        @mouseX = event.clientX
        @mouseY = event.clientY
        
        if @downPos.dist(new Vector @mouseX, @mouseY) > 60
            @mouseMoved = true
        
        if event.buttons & 4
            s = @dist * 0.001
            @pan x*s, y*s
            
        if event.buttons & 2
            @pivot x, y
            
    # 00000000   000  000   000   0000000   000000000  
    # 000   000  000  000   000  000   000     000     
    # 00000000   000   000 000   000   000     000     
    # 000        000     000     000   000     000     
    # 000        000      0       0000000      000     
    
    pivot: (x,y) ->
        
        # br = rts.elem.getBoundingClientRect()
        # relMouse = new THREE.Vector2 ((@mouseX-br.left)/br.width)*2-1, -((@mouseY-br.top)/br.height)*2+1 # [-1..1] [-1..1] left to right, bottom to top
        # rayDirection = new THREE.Vector3 relMouse.x, relMouse.y, 1 # point on far frustum
        # rayDirection.unproject @ # point on far plane
        # rayDirection.normalize()
#         
        # planeNormal = new THREE.Vector3(0,0,1).applyQuaternion @rotQuat()
#         
        # plane = new THREE.Plane 
        # plane.setFromNormalAndCoplanarPoint planeNormal, @center
        # ray = new THREE.Ray @position, rayDirection
        # planeHit = new THREE.Vector3
        # ray.intersectPlane plane, planeHit

        # rayDirection = new THREE.Vector3 ((@mouseX-br.left-x)/br.width)*2-1, -((@mouseY-br.top-y)/br.height)*2+1, 1
        # rayDirection.unproject @
        # rayDirection.normalize()
#         
        # deltaHit = new THREE.Vector3
        # ray = new THREE.Ray @position, rayDirection
        # ray.intersectPlane plane, deltaHit 
        # centerToOld = new THREE.Vector3().subVectors deltaHit, @center
        # centerToNew = new THREE.Vector3().subVectors planeHit, @center
        # angle = rad2deg centerToNew.angleTo centerToOld
        # centerToOldNorm = centerToOld.clone().normalize()
        # centerToNewNorm = centerToNew.clone().normalize()
        # cross = centerToOld.clone().cross(planeNormal)
        # dotp = cross.dot(centerToNewNorm)
        # asign = dotp > 0 and 1 or -1
        
        @rotate += -0.08*x
        @degree += -0.1*y
        
        @update()
               
    # 00000000    0000000   000   000  
    # 000   000  000   000  0000  000  
    # 00000000   000000000  000 0 000  
    # 000        000   000  000  0000  
    # 000        000   000  000   000  
    
    pan: (x,y) ->
        
        right = new THREE.Vector3 -x, 0, 0 
        right.applyQuaternion @quaternion

        up = new THREE.Vector3 0, y, 0 
        up.applyQuaternion @quaternion
        
        @center.add right.add up
        @centerTarget?.copy @center
        @update()
            
    # 00000000   0000000    0000000  000   000   0000000  
    # 000       000   000  000       000   000  000       
    # 000000    000   000  000       000   000  0000000   
    # 000       000   000  000       000   000       000  
    # 000        0000000    0000000   0000000   0000000   
    
    focusOnHit: ->
        
        raycaster = new THREE.Raycaster
        raycaster.setFromCamera rts.mouse, @
        intersects = raycaster.intersectObjects rts.scene.children, true

        intersects = intersects.filter (i) -> valid i.face
        
        if intersects.length
            @centerTarget = new Vector(intersects[0].point).round()
            @startFadeCenter()
            
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

        q = new THREE.Quaternion()
        q.multiply new THREE.Quaternion().setFromAxisAngle new THREE.Vector3(0, 0, 1), deg2rad @rotate
        q.multiply new THREE.Quaternion().setFromAxisAngle new THREE.Vector3(1, 0, 0), deg2rad @degree
        q
    
    update: -> 
        
        @degree = clamp 0, 180, @degree
        q = @rotQuat()
        @position.copy @center.plus new THREE.Vector3(0,0,@dist).applyQuaternion q
        @quaternion.copy q

module.exports = Camera
