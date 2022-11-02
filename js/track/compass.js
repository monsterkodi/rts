// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}}

var Compass


Compass = (function ()
{
    function Compass ()
    {
        var dot, geom, i

        this["onDoubleClick"] = this["onDoubleClick"].bind(this)
        this["onClick"] = this["onClick"].bind(this)
        this["onMouseUp"] = this["onMouseUp"].bind(this)
        this["onMouseDown"] = this["onMouseDown"].bind(this)
        this["onLeave"] = this["onLeave"].bind(this)
        this["onEnter"] = this["onEnter"].bind(this)
        this["onRotate"] = this["onRotate"].bind(this)
        this["onDelete"] = this["onDelete"].bind(this)
        this.dots = []
        this.group = new Group
        this.group.name = 'compass'
        geom = Geom.cylindonut(0.71,1.5,Math.sqrt(2) / 2,32)
        this.wheel = new Mesh(geom,Materials.compass.wheel)
        this.wheel.onDrag = this.onRotate
        this.wheel.name = 'compass.wheel'
        this.group.add(this.wheel)
        geom = new CylinderGeometry(0.2,0.2,1.2,16)
        geom.rotateX(Math.PI / 2)
        geom.translate(0,1.16,0)
        this.head = new Mesh(geom,Materials.compass.head)
        this.head.noHitTest = true
        this.head.name = 'compass.head'
        this.wheel.add(this.head)
        post.on('delete',this.onDelete)
        for (i = 0; i < 8; i++)
        {
            geom = new CylinderGeometry(0.33,0.33,0.71 * 1.2,24)
            geom.rotateX(Math.PI / 2)
            geom.translate(0,1.1,0)
            geom.rotateZ(i * Math.PI / 4)
            dot = new Mesh(geom,Materials.compass['dot' + i])
            dot.onDrag = this.onRotate
            dot.handler = this
            dot.name = `compass.dot${i}`
            this.dots.push(dot)
            this.group.add(dot)
        }
    }

    Compass.prototype["onDelete"] = function ()
    {
        var _46_24_

        return (this.object != null ? this.object.del() : undefined)
    }

    Compass.prototype["onRotate"] = function (hit, downHit, lastHit)
    {
        var angle, dir, plane, point

        this.clearHighlight()
        point = vec(this.group.position)
        plane = new Plane
        plane.setFromNormalAndCoplanarPoint(Vector.unitZ,point)
        lastHit.ray.intersectPlane(plane,Vector.tmp)
        hit.ray.intersectPlane(plane,Vector.tmp2)
        Vector.tmp.sub(point)
        Vector.tmp2.sub(point)
        dir = this.getDir()
        angle = dir.angle(Vector.tmp2) - dir.angle(Vector.tmp)
        if (angle)
        {
            return this.rotateBy(Math.sign(dir.crossed(this.getUp()).dot(Vector.tmp))* - angle)
        }
    }

    Compass.prototype["rotateBy"] = function (degree)
    {
        var _67_15_, _67_31_

        this.wheel.quaternion.multiply(Quaternion.axisAngle(this.getUp(),degree))
        return ((_67_15_=this.object) != null ? typeof (_67_31_=_67_15_.compassRotated) === "function" ? _67_31_(this.getDir()) : undefined : undefined)
    }

    Compass.prototype["rotateTo"] = function (degree)
    {
        var _73_15_, _73_31_

        this.wheel.quaternion.identity()
        this.wheel.quaternion.copy(Quaternion.axisAngle(this.getUp(),degree))
        return ((_73_15_=this.object) != null ? typeof (_73_31_=_73_15_.compassRotated) === "function" ? _73_31_(this.getDir()) : undefined : undefined)
    }

    Compass.prototype["setDir"] = function (dir)
    {
        var _78_15_, _78_31_

        this.wheel.quaternion.copy(Quaternion.unitVectors(Vector.unitY,dir))
        return ((_78_15_=this.object) != null ? typeof (_78_31_=_78_15_.compassRotated) === "function" ? _78_31_(this.getDir()) : undefined : undefined)
    }

    Compass.prototype["getDir"] = function ()
    {
        return vec(0,1,0).applyQuaternion(this.wheel.quaternion)
    }

    Compass.prototype["getUp"] = function ()
    {
        return vec(0,0,1).applyQuaternion(this.wheel.quaternion)
    }

    Compass.prototype["onEnter"] = function (hit)
    {
        var dot

        if (hit.name.startsWith('compass.dot'))
        {
            dot = this.dots[parseInt(hit.name.slice(-1)[0])]
            dot.scale.set(1,1,1.2)
            return dot.material.emissive.copy(dot.material.color)
        }
    }

    Compass.prototype["onLeave"] = function (hit)
    {
        var dot

        if (hit.name.startsWith('compass.dot'))
        {
            dot = this.dots[parseInt(hit.name.slice(-1)[0])]
            dot.scale.set(1,1,1)
            return dot.material.emissive.copy(Colors.black)
        }
    }

    Compass.prototype["onMouseDown"] = function (hit, downHit)
    {
        var dotIndex

        if (hit.name.startsWith('compass.dot'))
        {
            dotIndex = parseInt(hit.name.slice(-1)[0])
            return this.dots[dotIndex].scale.set(1,1,1)
        }
    }

    Compass.prototype["onMouseUp"] = function (hit, downHit)
    {
        return this.group.visible = true
    }

    Compass.prototype["onClick"] = function (hit, downHit)
    {
        var dotIndex

        if (hit.name.startsWith('compass.dot'))
        {
            dotIndex = parseInt(hit.name.slice(-1)[0])
            this.dots[dotIndex].scale.set(1,1,1.2)
            return this.rotateTo(dotIndex * 360 / 8)
        }
    }

    Compass.prototype["onDoubleClick"] = function (hit, downHit)
    {
        var _117_19_, _117_47_

        if (hit.name === 'compass.center')
        {
            return ((_117_19_=this.object) != null ? typeof (_117_47_=_117_19_.compassCenterDoubleClicked) === "function" ? _117_47_() : undefined : undefined)
        }
        else
        {
            console.log('onDoubleClick',hit)
        }
    }

    Compass.prototype["clearHighlight"] = function ()
    {
        var dot

        var list = _k_.list(this.dots)
        for (var _123_16_ = 0; _123_16_ < list.length; _123_16_++)
        {
            dot = list[_123_16_]
            dot.scale.set(1,1,1)
            dot.material.emissive.copy(Colors.black)
        }
    }

    return Compass
})()

module.exports = Compass