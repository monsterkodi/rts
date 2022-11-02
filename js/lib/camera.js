// monsterkodi/kode 0.243.0

var _k_ = {clamp: function (l,h,v) { var ll = Math.min(l,h), hh = Math.max(l,h); if (!_k_.isNum(v)) { v = ll }; if (v < ll) { v = ll }; if (v > hh) { v = hh }; if (!_k_.isNum(v)) { v = ll }; return v }, isNum: function (o) {return !isNaN(o) && !isNaN(parseFloat(o)) && (isFinite(o) || o === Infinity || o === -Infinity)}}

var PerspectiveCamera, prefs, reduce, THREE

clamp = require('kxk').clamp
prefs = require('kxk').prefs
reduce = require('kxk').reduce

THREE = require('three')
PerspectiveCamera = THREE.PerspectiveCamera
class Camera extends PerspectiveCamera
{
    constructor (opt)
    {
        super(70,width / height,1,1000)
    
        var height, width

        this.setDistFactor = this.setDistFactor.bind(this)
        this.inertZoom = this.inertZoom.bind(this)
        this.onMouseWheel = this.onMouseWheel.bind(this)
        this.moveCenter = this.moveCenter.bind(this)
        this.fadeCenter = this.fadeCenter.bind(this)
        this.panBlocks = this.panBlocks.bind(this)
        this.pivotCenter = this.pivotCenter.bind(this)
        this.onMouseDrag = this.onMouseDrag.bind(this)
        this.onDblClick = this.onDblClick.bind(this)
        this.onMouseUp = this.onMouseUp.bind(this)
        this.onMouseDown = this.onMouseDown.bind(this)
        this.del = this.del.bind(this)
        width = opt.view.clientWidth
        height = opt.view.clientHeight
        this.fov = 70
        this.size = vec(width,height)
        this.elem = opt.view
        this.dist = 10
        this.maxDist = this.far / 2
        this.minDist = this.near * 2
        this.center = vec()
        this.degree = 60
        this.rotate = 0
        this.wheelInert = 0
        this.pivotX = 0
        this.pivotY = 0
        this.moveX = 0
        this.moveY = 0
        this.moveZ = 0
        this.mouse = vec()
        this.downPos = vec()
        this.centerTarget = vec()
        this.quat = quat()
        this.elem.addEventListener('mousewheel',this.onMouseWheel)
        this.elem.addEventListener('mousedown',this.onMouseDown)
        this.elem.addEventListener('keypress',this.onKeyPress)
        this.elem.addEventListener('keyrelease',this.onKeyRelease)
        this.elem.addEventListener('dblclick',this.onDblClick)
        this.update()
    }

    getPosition ()
    {
        return vec(this.position)
    }

    getDir ()
    {
        return quat(this.quaternion).rotate(Vector.minusZ)
    }

    getUp ()
    {
        return quat(this.quaternion).rotate(Vector.unitY)
    }

    getRight ()
    {
        return quat(this.quaternion).rotate(Vector.unitX)
    }

    del ()
    {
        this.elem.removeEventListener('keypress',this.onKeyPress)
        this.elem.removeEventListener('keyrelease',this.onKeyRelease)
        this.elem.removeEventListener('mousewheel',this.onMouseWheel)
        this.elem.removeEventListener('mousedown',this.onMouseDown)
        this.elem.removeEventListener('dblclick',this.onDblClick)
        window.removeEventListener('mouseup',this.onMouseUp)
        return window.removeEventListener('mousemove',this.onMouseDrag)
    }

    onMouseDown (event)
    {
        this.downButtons = event.buttons
        this.mouseMoved = false
        this.mouse.x = event.clientX
        this.mouse.y = event.clientY
        this.downPos.copy(this.mouse)
        window.addEventListener('mousemove',this.onMouseDrag)
        return window.addEventListener('mouseup',this.onMouseUp)
    }

    onMouseUp (event)
    {
        window.removeEventListener('mousemove',this.onMouseDrag)
        return window.removeEventListener('mouseup',this.onMouseUp)
    }

    onDblClick (event)
    {}

    onMouseDrag (event)
    {
        var s, x, y

        x = event.clientX - this.mouse.x
        y = event.clientY - this.mouse.y
        this.mouse.x = event.clientX
        this.mouse.y = event.clientY
        if (this.downPos.dist(this.mouse) > 60)
        {
            this.mouseMoved = true
        }
        if (event.buttons === 4)
        {
            s = this.dist
        }
        if (this.downPos.dist(this.mouse) > 60)
        {
            this.mouseMoved = true
        }
        if (event.buttons === 4)
        {
            s = this.dist
            this.pan(x * 2 * s / this.size.x,y * s / this.size.y)
        }
        if (event.buttons === 2)
        {
            return this.pivot(4000 * x / this.size.x,2000 * y / this.size.y)
        }
    }

    pivot (x, y)
    {
        this.rotate += -0.1 * x
        this.degree += -0.1 * y
        this.storePrefs()
        return this.update()
    }

    startPivotLeft ()
    {
        this.pivotX = 20
        return this.startPivot()
    }

    startPivotRight ()
    {
        this.pivotX = -20
        return this.startPivot()
    }

    startPivotUp ()
    {
        this.pivotY = -10
        return this.startPivot()
    }

    startPivotDown ()
    {
        this.pivotY = 10
        return this.startPivot()
    }

    stopPivot ()
    {
        this.pivoting = false
        this.pivotX = 0
        return this.pivotY = 0
    }

    startPivot ()
    {
        if (!this.pivoting)
        {
            rts.animate(this.pivotCenter)
            return this.pivoting = true
        }
    }

    pivotCenter (deltaSeconds)
    {
        if (!this.pivoting)
        {
            return
        }
        this.pivot(this.pivotX,this.pivotY)
        return rts.animate(this.pivotCenter)
    }

    pan (x, y)
    {
        Vector.tmp.set(-x,0,0)
        Vector.tmp.applyQuaternion(this.quaternion)
        this.center.add(Vector.tmp)
        Vector.tmp.set(0,y,0)
        Vector.tmp.applyQuaternion(this.quaternion)
        this.center.add(Vector.tmp)
        this.centerTarget.copy(this.center)
        this.stopZoom()
        this.storePrefs()
        this.update()
        if (!this.panBlocksWheel)
        {
            this.panBlocksWheel = 1.0
            return rts.animate(this.panBlocks)
        }
    }

    panBlocks (deltaSeconds)
    {
        this.panBlocksWheel -= deltaSeconds
        if (this.panBlocksWheel < 0)
        {
            return delete this.panBlocksWheel
        }
        else
        {
            return rts.animate(this.panBlocks)
        }
    }

    focusOnPoint (v)
    {
        this.centerTarget.copy(v)
        this.center.copy(v)
        return this.update()
    }

    fadeToPoint (v)
    {
        this.centerTarget.copy(v)
        this.storePrefs()
        return this.startFadeCenter()
    }

    startFadeCenter ()
    {
        if (!this.fading)
        {
            rts.animate(this.fadeCenter)
            return this.fading = true
        }
    }

    stopFading ()
    {
        return this.fading = false
    }

    fadeCenter (deltaSeconds)
    {
        if (!this.fading)
        {
            return
        }
        this.center.fade(this.centerTarget,deltaSeconds)
        this.update()
        if (this.center.dist(this.centerTarget) > 0.00001)
        {
            return rts.animate(this.fadeCenter)
        }
        else
        {
            return delete this.fading
        }
    }

    moveFactor ()
    {
        return this.dist / 2
    }

    startMoveForward ()
    {
        this.moveZ = -this.moveFactor()
        return this.startMove()
    }

    startMoveBackward ()
    {
        this.moveZ = this.moveFactor()
        return this.startMove()
    }

    startMoveLeft ()
    {
        this.moveX = -this.moveFactor()
        return this.startMove()
    }

    startMoveRight ()
    {
        this.moveX = this.moveFactor()
        return this.startMove()
    }

    startMoveUp ()
    {
        this.moveY = this.moveFactor()
        return this.startMove()
    }

    startMoveDown ()
    {
        this.moveY = -this.moveFactor()
        return this.startMove()
    }

    stopMoving ()
    {
        this.moving = false
        this.moveX = 0
        this.moveY = 0
        return this.moveZ = 0
    }

    startMove ()
    {
        this.stopFading()
        if (!this.moving)
        {
            rts.animate(this.moveCenter)
            return this.moving = true
        }
    }

    moveCenter (deltaSeconds)
    {
        var dir

        if (!this.moving)
        {
            return
        }
        dir = vec()
        dir.add(Vector.unitX.mul(this.moveX))
        dir.add(Vector.unitY.mul(this.moveY))
        dir.add(Vector.unitZ.mul(this.moveZ))
        dir.scale(deltaSeconds)
        dir.applyQuaternion(this.quaternion)
        this.center.add(dir)
        this.update()
        return rts.animate(this.moveCenter)
    }

    moveLeft ()
    {
        return this.moveXYZ(-1,0,0)
    }

    moveRight ()
    {
        return this.moveXYZ(1,0,0)
    }

    moveUp ()
    {
        return this.moveXYZ(0,1,0)
    }

    moveDown ()
    {
        return this.moveXYZ(0,-1,0)
    }

    moveForward ()
    {
        return this.moveXYZ(0,0,-1)
    }

    moveBackward ()
    {
        return this.moveXYZ(0,0,1)
    }

    moveXYZ (x, y, z)
    {
        this.stopMoving()
        this.stopFading()
        this.center.add(vec(x,y,z).applyQuaternion(this.quaternion))
        return this.update()
    }

    onMouseWheel (event)
    {
        if (this.wheelInert > 0 && event.wheelDelta < 0)
        {
            this.wheelInert = 0
            return
        }
        if (this.wheelInert < 0 && event.wheelDelta > 0)
        {
            this.wheelInert = 0
            return
        }
        if (this.panBlocksWheel)
        {
            return
        }
        if (Math.abs(this.wheelInert) < 0.0001)
        {
            this.wheelInert += event.wheelDelta * (1 + (this.dist / this.maxDist) * 3) * 0.00005
        }
        else
        {
            this.wheelInert += event.wheelDelta * (1 + (this.dist / this.maxDist) * 3) * 0.0002
        }
        if (Math.abs(this.wheelInert) > 0.00003)
        {
            return this.startZoom()
        }
    }

    startZoomIn ()
    {
        this.wheelInert = (1 + (this.dist / this.maxDist) * 3) * 10
        return this.startZoom()
    }

    startZoomOut ()
    {
        this.wheelInert = -(1 + (this.dist / this.maxDist) * 3) * 10
        return this.startZoom()
    }

    startZoom ()
    {
        if (!this.zooming)
        {
            rts.animate(this.inertZoom)
            return this.zooming = true
        }
    }

    stopZoom ()
    {
        this.wheelInert = 0
        return this.zooming = false
    }

    inertZoom (deltaSeconds)
    {
        this.setDistFactor(1 - _k_.clamp(-0.02,0.02,this.wheelInert))
        this.wheelInert = reduce(this.wheelInert,deltaSeconds * 0.3)
        if (Math.abs(this.wheelInert) > 0.00000001)
        {
            return rts.animate(this.inertZoom)
        }
        else
        {
            delete this.zooming
            return this.wheelInert = 0
        }
    }

    setDistFactor (factor)
    {
        this.dist = _k_.clamp(this.minDist,this.maxDist,this.dist * factor)
        return this.update()
    }

    setFov (fov)
    {
        return this.fov = _k_.clamp(2.0,175.0,fov)
    }

    storePrefs ()
    {
        return prefs.set('camera',{degree:this.degree,rotate:this.rotate,dist:this.dist,center:{x:this.centerTarget.x,y:this.centerTarget.y,z:this.centerTarget.z}})
    }

    update ()
    {
        var compass, s, _435_33_

        this.degree = _k_.clamp(0,180,this.degree)
        this.quat.reset()
        this.quat.rotateAxisAngle(Vector.unitZ,this.rotate)
        this.quat.rotateAxisAngle(Vector.unitX,this.degree)
        this.position.copy(this.center)
        Vector.tmp.set(0,0,this.dist)
        Vector.tmp.applyQuaternion(this.quat)
        this.position.add(Vector.tmp)
        this.quaternion.copy(this.quat)
        this.updateProjectionMatrix()
        if (compass = (window.world != null ? window.world.compass : undefined))
        {
            s = _k_.clamp(1,6,this.dist / 30)
            return compass.group.scale.set(s,s,s)
        }
    }
}

module.exports = Camera