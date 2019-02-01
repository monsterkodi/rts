###
 0000000   0000000   00     00  00000000  00000000    0000000 
000       000   000  000   000  000       000   000  000   000
000       000000000  000000000  0000000   0000000    000000000
000       000   000  000 0 000  000       000   000  000   000
 0000000  000   000  000   000  00000000  000   000  000   000
###

{ clamp, log } = require 'kxk'

Vector      = require './lib/vector'
Quaternion  = require './lib/quaternion'
THREE       = require 'three'

class Camera extends THREE.PerspectiveCamera

    constructor: (opt) ->
        
        fov     = opt.fov    ? 60
        near    = opt.near   ? 0.01
        far     = opt.far    ? 300
        aspect  = opt.aspect ? 1
        
        super fov, aspect, near, far
        
        @fov     = fov
        @near    = near
        @far     = far
        @aspect  = aspect
        @elem    = opt.view
        @dist    = opt.dist or 3
        @maxDist = opt.maxDist or @far/2
        @minDist = opt.minDist or 2
        @center  = new Vector 0, 0, 0

        @elem.addEventListener 'mousewheel', @onMouseWheel
        @elem.addEventListener 'mousedown',  @onMouseDown
        @elem.addEventListener 'keypress',   @onKeyPress
        @elem.addEventListener 'keyrelease', @onKeyRelease
        
        @position.set 0, 0, @dist

    reset: ->
        @lookAt 0,0,0
        @quaternion.copy Quaternion.ZupY

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
        @isPivoting = true
        
    onMouseUp: (event) => 
        window.removeEventListener 'mousemove',  @onMouseDrag
        window.removeEventListener 'mouseup',    @onMouseUp
        @isPivoting = false  
        
    onMouseDrag:  (event) =>  
        return if not @isPivoting
        x = @mouseX-event.clientX
        y = @mouseY-event.clientY
        @mouseX = event.clientX
        @mouseY = event.clientY
        @pivot x*0.005, y*0.005
        
    pivot: (x,y) ->
        q = @quaternion.clone()
        q.multiply new THREE.Quaternion().setFromAxisAngle new THREE.Vector3(1, 0, 0), y
        q.multiply new THREE.Quaternion().setFromAxisAngle new THREE.Vector3(0, 1, 0), x
        @position.copy @center.plus new THREE.Vector3(0,0,@dist).applyQuaternion q
        @quaternion.copy q

    onMouseWheel: (event) => @setDist 1-event.wheelDelta/10000
    
    setDist: (factor) =>
        @dist = clamp @minDist, @maxDist, @dist*factor
        @position.copy @center.plus new THREE.Vector3(0,0,@dist).applyQuaternion @quaternion
        
    lookAt: (x,y,z) ->
        @center = new Vector x,y,z 
        @position.copy @center.plus new THREE.Vector3(0,0,@dist).applyQuaternion @quaternion
        
    setFov: (fov) -> @fov = Math.max(2.0, Math.min fov, 175.0)
        
module.exports = Camera