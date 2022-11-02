// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}}

var ModeSign


ModeSign = (function ()
{
    ModeSign["twoway"] = 0
    ModeSign["forward"] = 1
    ModeSign["backward"] = 2
    function ModeSign (track)
    {
        this.track = track
    
        this["onLeave"] = this["onLeave"].bind(this)
        this["onEnter"] = this["onEnter"].bind(this)
        this["onClick"] = this["onClick"].bind(this)
    }

    ModeSign.prototype["del"] = function ()
    {
        return this.mesh.removeFromParent()
    }

    ModeSign.prototype["matName"] = function ()
    {
        switch (this.track.mode)
        {
            case ModeSign.twoway:
                return 'twoway'

            case ModeSign.forward:
            case ModeSign.backward:
                return 'oneway'

        }

    }

    ModeSign.prototype["updateMode"] = function ()
    {
        var geom, mat, _26_16_, _30_13_

        if ((this.mesh != null ? this.mesh.material : undefined) === Materials.track.mode.highlight)
        {
            mat = this.mesh.material
        }
        else
        {
            mat = Materials.track.mode[this.matName()]
        }
        ;(this.mesh != null ? this.mesh.removeFromParent() : undefined)
        switch (this.track.mode)
        {
            case ModeSign.twoway:
                geom = Geom.cylinder({radius:0.25,height:0.72})
                break
            case ModeSign.forward:
                geom = Geom.triangle({width:0.5,height:0.72,depth:1})
                break
            case ModeSign.backward:
                geom = Geom.triangle({width:0.5,height:0.72,depth:1})
                geom.rotateZ(deg2rad(180))
                break
        }

        this.mesh = new THREE.InstancedMesh(geom,mat,100)
        this.mesh.handler = this
        this.setCurve(this.track.curve)
        return this.track.mesh.add(this.mesh)
    }

    ModeSign.prototype["onClick"] = function (hit, event)
    {
        return this.track.nextMode()
    }

    ModeSign.prototype["onEnter"] = function (hit, nextHit, event)
    {
        return this.mesh.material = Materials.track.mode.highlight
    }

    ModeSign.prototype["onLeave"] = function (hit, nextHit, event)
    {
        return this.mesh.material = Materials.track.mode[this.matName()]
    }

    ModeSign.prototype["setCurve"] = function (curve)
    {
        var curveLength, index, mat, point, points, quat, tangent

        curveLength = curve.getLength()
        points = curve.getSpacedPoints(parseInt(curveLength / 4))
        if (points.length >= 5)
        {
            points.pop()
            points.pop()
            points.shift()
            points.shift()
        }
        else
        {
            points = [curve.getPointAt(0.5)]
        }
        mat = new THREE.Matrix4
        var list = _k_.list(points)
        for (index = 0; index < list.length; index++)
        {
            point = list[index]
            tangent = curve.getTangentAt((index + 2) / (points.length - 1 + 4))
            quat = Quaternion.unitVectors(Vector.unitY,tangent)
            mat.compose(point,quat,vec(1,1,1))
            this.mesh.setMatrixAt(index,mat)
        }
        this.mesh.count = points.length
        return this.mesh.instanceMatrix.needsUpdate = true
    }

    return ModeSign
})()

module.exports = ModeSign