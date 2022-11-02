// monsterkodi/kode 0.243.0

var _k_

var CurveCtrl, MIN_CTRL_DIST

MIN_CTRL_DIST = 2

CurveCtrl = (function ()
{
    CurveCtrl["active"] = new Set
    CurveCtrl["deactivateAll"] = function ()
    {
        return CurveCtrl.active.forEach(function (ctrl)
        {
            return ctrl.deactivate()
        })
    }

    function CurveCtrl (track, index)
    {
        var geom, mesh

        this.track = track
        this.index = index
    
        this["compassRotated"] = this["compassRotated"].bind(this)
        this["onDrag"] = this["onDrag"].bind(this)
        this["onDragDone"] = this["onDragDone"].bind(this)
        this["deactivate"] = this["deactivate"].bind(this)
        this["activate"] = this["activate"].bind(this)
        this["isActive"] = this["isActive"].bind(this)
        this["onDelete"] = this["onDelete"].bind(this)
        this["onEnter"] = this["onEnter"].bind(this)
        this["onLeave"] = this["onLeave"].bind(this)
        this["onCenterClick"] = this["onCenterClick"].bind(this)
        this["compassCenterDoubleClicked"] = this["compassCenterDoubleClicked"].bind(this)
        this.curvePath = this.track.curve
        this.curve = this.curvePath.curves[this.index]
        this.isLast = this.index === this.curvePath.curves.length - 1
        this.isFirst = this.index === 0
        this.isMid = !this.isFirst
        this.curveStart = this.curve.v0
        this.ctrlStart = this.curve.v1
        this.ctrlEnd = this.curve.v2
        this.curveEnd = this.curve.v3
        this.group = new Group
        this.group.name = 'ctrl'
        if (this.isMid)
        {
            mesh = new Mesh(Geom.box(),Materials.ctrl.start)
            this.prevCtrlEnd = this.curvePath.curves[this.index - 1].v2
            mesh.position.y = -this.prevCtrlDist()
            mesh.onDrag = this.onDrag
            mesh.onDragDone = this.onDragDone
            mesh.name = 'prevCtrlEnd'
            mesh.handler = this
            mesh.visible = false
            this.meshPrevCtrlEnd = mesh
            this.group.add(this.meshPrevCtrlEnd)
            geom = Geom.box({size:[0.35,1,0.35]})
            mesh = new Mesh(geom,Materials.ctrl.start)
            mesh.scale.set(1,this.prevCtrlDist(),1)
            mesh.position.y = -this.prevCtrlDist() / 2
            mesh.name = 'prevCtrlRod'
            mesh.visible = false
            this.meshPrevCtrlRod = mesh
            this.group.add(this.meshPrevCtrlRod)
        }
        if (!this.isFirst)
        {
            geom = Geom.cylinder({height:0.71,radius:0.7,smnt:32})
            mesh = new Mesh(geom,Materials.ctrl.curve)
            mesh.onDrag = this.onDrag
            mesh.onDragDone = this.onDragDone
            mesh.onClick = this.onCenterClick
            mesh.name = 'curveStart'
            mesh.handler = this
            mesh.setShadow()
            this.meshCurveStart = mesh
            world.addPickable(this.meshCurveStart)
            this.group.add(this.meshCurveStart)
        }
        mesh = new Mesh(Geom.box(),Materials.ctrl.start)
        if (!this.isFirst)
        {
            mesh.onDrag = this.onDrag
            mesh.onDragDone = this.onDragDone
        }
        else
        {
            mesh.material = Materials.ctrl.transparent
        }
        mesh.handler = this
        mesh.position.y = this.ctrlStartDist()
        mesh.name = 'ctrlStart'
        mesh.visible = false
        this.meshCtrlStart = mesh
        this.group.add(this.meshCtrlStart)
        geom = Geom.box({size:[0.35,1,0.35]})
        mesh = new Mesh(geom,Materials.ctrl.start)
        mesh.scale.set(1,this.ctrlStartDist(),1)
        mesh.position.y = this.ctrlStartDist() / 2
        mesh.name = 'ctrlRod'
        mesh.visible = false
        this.meshCtrlRod = mesh
        this.group.add(this.meshCtrlRod)
        this.group.position.copy(this.curveStart)
        this.setDir(this.curve.getTangent(0,Vector.tmp),false)
        world.addObject(this.group)
    }

    CurveCtrl.prototype["del"] = function ()
    {
        world.hideCompass(this)
        world.removeObject(this.group)
        world.removePickable(this.meshCurveStart)
        delete this.group
        delete this.meshCtrlStart
        delete this.meshCurveStart
        return delete this.meshPrevCtrlEnd
    }

    CurveCtrl.prototype["compassCenterDoubleClicked"] = function ()
    {
        return post.emit('convertCtrlToNode',this)
    }

    CurveCtrl.prototype["onCenterClick"] = function ()
    {
        if (world.compass.object === this)
        {
            return world.hideCompass(this)
        }
        else
        {
            return world.showCompass(this,this.getPos(),this.getDir())
        }
    }

    CurveCtrl.prototype["onLeave"] = function (hit, nextHit, event)
    {
        var _126_32_, _127_32_, _129_30_, _130_28_

        if (event.buttons === 0)
        {
            if (hit.mesh.name === 'prevCtrlEnd')
            {
                if ((this.meshPrevCtrlEnd != null)) { this.meshPrevCtrlEnd.material = Materials.ctrl.start }
                if ((this.meshPrevCtrlRod != null)) { this.meshPrevCtrlRod.material = Materials.ctrl.start }
            }
            if (hit.mesh.name === 'ctrlStart')
            {
                if ((this.meshCtrlStart != null)) { this.meshCtrlStart.material = Materials.ctrl.start }
                if ((this.meshCtrlRod != null)) { this.meshCtrlRod.material = Materials.ctrl.start }
            }
            if (hit.mesh.name === 'curveStart')
            {
                post.removeListener('delete',this.onDelete)
                this.meshCurveStart.material = Materials.ctrl.curve
            }
        }
        return this
    }

    CurveCtrl.prototype["onEnter"] = function (hit)
    {
        var _140_32_, _141_32_, _143_30_, _144_28_

        if (event.buttons === 0)
        {
            if (hit.mesh.name === 'prevCtrlEnd')
            {
                if ((this.meshPrevCtrlEnd != null)) { this.meshPrevCtrlEnd.material = Materials.ctrl.highlight }
                if ((this.meshPrevCtrlRod != null)) { this.meshPrevCtrlRod.material = Materials.ctrl.highlight }
            }
            if (hit.mesh.name === 'ctrlStart')
            {
                if ((this.meshCtrlStart != null)) { this.meshCtrlStart.material = Materials.ctrl.highlight }
                if ((this.meshCtrlRod != null)) { this.meshCtrlRod.material = Materials.ctrl.highlight }
            }
            if (hit.mesh.name === 'curveStart')
            {
                this.meshCurveStart.material = Materials.ctrl.highlight
                post.on('delete',this.onDelete)
                this.activate()
            }
        }
        return this
    }

    CurveCtrl.prototype["onDelete"] = function ()
    {
        console.log('delete ctrl!')
    }

    CurveCtrl.prototype["isActive"] = function ()
    {
        return CurveCtrl.active.has(this)
    }

    CurveCtrl.prototype["activate"] = function ()
    {
        if (this.isActive())
        {
            return
        }
        CurveCtrl.active.add(this)
        this.meshPrevCtrlEnd.visible = true
        this.meshPrevCtrlRod.visible = true
        this.meshCtrlStart.visible = true
        this.meshCtrlRod.visible = true
        world.addPickable(this.meshPrevCtrlEnd)
        return world.addPickable(this.meshCtrlStart)
    }

    CurveCtrl.prototype["deactivate"] = function ()
    {
        var _177_24_, _178_24_, _179_22_, _180_20_, _182_23_

        world.hideCompass(this)
        if (!this.isActive())
        {
            return
        }
        CurveCtrl.active.delete(this)
        if ((this.meshPrevCtrlEnd != null)) { this.meshPrevCtrlEnd.visible = false }
        if ((this.meshPrevCtrlRod != null)) { this.meshPrevCtrlRod.visible = false }
        if ((this.meshCtrlStart != null)) { this.meshCtrlStart.visible = false }
        if ((this.meshCtrlRod != null)) { this.meshCtrlRod.visible = false }
        if ((this.meshCurveStart != null)) { this.meshCurveStart.material = Materials.ctrl.curve }
        world.removePickable(this.meshPrevCtrlEnd)
        return world.removePickable(this.meshCtrlStart)
    }

    CurveCtrl.prototype["prevCtrlDist"] = function ()
    {
        return this.prevCtrlEnd.distanceTo(this.curveStart)
    }

    CurveCtrl.prototype["ctrlStartDist"] = function ()
    {
        return this.ctrlStart.distanceTo(this.curveStart)
    }

    CurveCtrl.prototype["onDragDone"] = function (hit, downHit)
    {
        var _199_36_, _200_36_, _202_30_, _203_28_

        if (hit.mesh.name !== downHit.mesh.name)
        {
            if (downHit.mesh.name === 'prevCtrlEnd')
            {
                if ((this.meshPrevCtrlEnd != null)) { this.meshPrevCtrlEnd.material = Materials.ctrl.start }
                if ((this.meshPrevCtrlRod != null)) { this.meshPrevCtrlRod.material = Materials.ctrl.start }
            }
            if (downHit.mesh.name === 'ctrlStart')
            {
                if ((this.meshCtrlStart != null)) { this.meshCtrlStart.material = Materials.ctrl.start }
                if ((this.meshCtrlRod != null)) { this.meshCtrlRod.material = Materials.ctrl.start }
            }
            if (downHit.mesh.name === 'curveStart')
            {
                return this.meshCurveStart.material = Materials.ctrl.curve
            }
        }
    }

    CurveCtrl.prototype["onDrag"] = function (hit, downHit)
    {
        var dist, newPos, plane, ray

        world.hideCompass(this)
        plane = new Plane
        plane.setFromNormalAndCoplanarPoint(Vector.unitZ,this.getPos())
        hit.ray.intersectPlane(plane,Vector.tmp)
        Vector.tmp.round()
        if (downHit.mesh.name === 'ctrlStart')
        {
            ray = new Ray(this.curveStart,this.getDir())
            newPos = vec()
            ray.closestPointToPoint(Vector.tmp,newPos)
            dist = newPos.distanceTo(this.curveStart)
            if (dist < 1)
            {
                return
            }
            if (dist < MIN_CTRL_DIST)
            {
                this.ctrlStart.sub(this.curveStart)
                this.ctrlStart.normalize()
                this.ctrlStart.multiplyScalar(MIN_CTRL_DIST)
                this.ctrlStart.add(this.curveStart)
                dist = this.ctrlStartDist()
            }
            else
            {
                this.ctrlStart.copy(newPos)
            }
            this.meshCtrlRod.position.y = dist / 2
            this.meshCtrlRod.scale.set(1,dist,1)
            this.meshCtrlStart.position.y = dist
        }
        if (downHit.mesh.name === 'prevCtrlEnd')
        {
            ray = new Ray(this.curveStart,this.getDir().negate())
            newPos = vec()
            ray.closestPointToPoint(Vector.tmp,newPos)
            dist = newPos.distanceTo(this.curveStart)
            if (dist < 1)
            {
                return
            }
            if (dist < MIN_CTRL_DIST)
            {
                this.prevCtrlEnd.sub(this.curveStart)
                this.prevCtrlEnd.normalize()
                this.prevCtrlEnd.multiplyScalar(MIN_CTRL_DIST)
                this.prevCtrlEnd.add(this.curveStart)
                dist = this.prevCtrlDist()
            }
            else
            {
                this.prevCtrlEnd.copy(newPos)
            }
            this.meshPrevCtrlRod.position.y = -dist / 2
            this.meshPrevCtrlRod.scale.set(1,dist,1)
            this.meshPrevCtrlEnd.position.y = -dist
        }
        if (downHit.mesh.name === 'curveStart')
        {
            this.setPos(Vector.tmp)
        }
        this.curve.updateArcLengths()
        return this.track.ctrlMoved()
    }

    CurveCtrl.prototype["compassRotated"] = function (dir)
    {
        return this.setDir(dir)
    }

    CurveCtrl.prototype["setDir"] = function (dir, moved = true)
    {
        var quat, _272_24_

        quat = Quaternion.unitVectors(Vector.unitY,dir)
        this.group.quaternion.copy(quat)
        this.meshCtrlStart.getWorldPosition(this.ctrlStart)
        ;(this.meshPrevCtrlEnd != null ? this.meshPrevCtrlEnd.getWorldPosition(this.prevCtrlEnd) : undefined)
        this.curve.updateArcLengths()
        if (moved)
        {
            return this.track.ctrlMoved()
        }
    }

    CurveCtrl.prototype["moveStartTo"] = function (point)
    {
        var delta

        delta = Vector.tmp.copy(point)
        delta.sub(this.curveStart)
        this.curveStart.add(delta)
        this.ctrlStart.add(delta)
        this.meshCtrlStart.position.copy(this.ctrlStart)
        return this.curve.updateArcLengths()
    }

    CurveCtrl.prototype["moveEndTo"] = function (point)
    {
        var delta

        delta = Vector.tmp.copy(point)
        delta.sub(this.curveEnd)
        this.curveEnd.add(delta)
        this.ctrlEnd.add(delta)
        return this.curve.updateArcLengths()
    }

    CurveCtrl.prototype["setPos"] = function (point)
    {
        var delta

        delta = vec(point).minus(this.curveStart)
        this.curveStart.add(delta)
        this.ctrlStart.add(delta)
        this.prevCtrlEnd.add(delta)
        this.group.position.copy(this.curveStart)
        this.curve.updateArcLengths()
        return this.track.ctrlMoved()
    }

    CurveCtrl.prototype["getPos"] = function ()
    {
        return this.group.position
    }

    CurveCtrl.prototype["getDir"] = function ()
    {
        return vec(0,1,0).applyQuaternion(this.group.quaternion)
    }

    CurveCtrl.prototype["rotateStart"] = function (dir)
    {
        var length

        length = this.ctrlStart.distanceTo(this.curveStart)
        this.ctrlStart.copy(dir)
        this.ctrlStart.setLength(length)
        this.ctrlStart.add(this.curveStart)
        return this.curve.updateArcLengths()
    }

    CurveCtrl.prototype["rotateEnd"] = function (dir)
    {
        var length

        length = this.ctrlEnd.distanceTo(this.curveEnd)
        this.ctrlEnd.copy(dir)
        this.ctrlEnd.setLength(length)
        this.ctrlEnd.add(this.curveEnd)
        return this.curve.updateArcLengths()
    }

    return CurveCtrl
})()

module.exports = CurveCtrl