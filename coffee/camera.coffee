###
 0000000   0000000   00     00  00000000  00000000    0000000 
000       000   000  000   000  000       000   000  000   000
000       000000000  000000000  0000000   0000000    000000000
000       000   000  000 0 000  000       000   000  000   000
 0000000  000   000  000   000  00000000  000   000  000   000
###

{ deg2rad, clamp, log } = require 'kxk'

Vector      = require './lib/vector'
Quaternion  = require './lib/quaternion'
THREE       = require 'three'

class Camera extends THREE.PerspectiveCamera

    constructor: (opt) ->
        
        aspect = opt.view.clientWidth / opt.view.clientHeight
        super 60, aspect, 0.01, 300 # fov, aspect, near, far
        
        @elem    = opt.view
        @dist    = @far/16
        @maxDist = @far/2
        @minDist = 2
        @center  = new Vector 0, 0, 0
        @degree  = 0
        @rotate  = 0

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

    onMouseDown: (event) => 
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
        
        if event.buttons & 1
            s = @dist * 0.001
            @move x*s, y*s
        if event.buttons & 4
            s = @dist * 0.001
            @pan x*s, y*s
        if event.buttons & 2
            s = 0.1
            @pivot x*s, y*s
            
    move: (x,y) -> @pan x,y
        
    pan: (x,y) ->
        
        right = new THREE.Vector3 x, 0, 0 
        right.applyQuaternion @quaternion

        up = new THREE.Vector3 0, -y, 0 
        up.applyQuaternion @quaternion
        
        @center.add right.add up
        @update()
            
    pivot: (x,y) ->
        @rotate += x
        @degree += y
        @update()
        
    update: -> 
        @degree = clamp 0, 180, @degree
        q = new THREE.Quaternion()
        q.multiply new THREE.Quaternion().setFromAxisAngle new THREE.Vector3(0, 0, 1), deg2rad @rotate
        q.multiply new THREE.Quaternion().setFromAxisAngle new THREE.Vector3(1, 0, 0), deg2rad @degree
        @position.copy @center.plus new THREE.Vector3(0,0,@dist).applyQuaternion q
        @quaternion.copy q

    onMouseWheel: (event) => @setDist 1-event.wheelDelta/10000
    
    setDist: (factor) =>
        @dist = clamp @minDist, @maxDist, @dist*factor
        @update()
        
    setFov: (fov) -> @fov = Math.max(2.0, Math.min fov, 175.0)
        
module.exports = Camera