// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}}

var CANNON, Needle

CANNON = require('cannon-es')

Needle = (function ()
{
    function Needle (cannon)
    {
        var geom

        this.cannon = cannon
    
        this.poleBody = new CANNON.Body({type:CANNON.Body.KINEMATIC})
        this.poleBody.keep = true
        this.poleBody.addShape(new CANNON.Cylinder(0.1,0.1,5,8))
        this.poleBody.addShape(new CANNON.Sphere(0.3))
        this.poleBody.shapeOffsets[0].y = 2.5
        this.poleBody.shapeOffsets[1].y = 5
        this.poleBody.quaternion.copy(Quaternion.unitVectors(Vector.unitY,Vector.unitZ))
        geom = Geom.merge(Geom.cylinder({radius:0.1,height:5,dir:Vector.unitY,pos:[0,2.5,0]}),Geom.sphere({radius:0.3,pos:[0,5,0]}))
        this.poleBody.mesh = new Mesh(geom,Materials.physics.chain)
        this.poleBody.mesh.setShadow()
        world.scene.add(this.poleBody.mesh)
        this.cannon.addBody(this.poleBody)
    }

    Needle.prototype["addChain"] = function ()
    {
        var ballPivot, cb, cbs, cstr, i, num, p, polePivot, r

        cbs = []
        num = 16
        for (var _42_17_ = i = 0, _42_21_ = num; (_42_17_ <= _42_21_ ? i < num : i > num); (_42_17_ <= _42_21_ ? ++i : --i))
        {
            p = this.poleBody.position
            r = 0.25 + (1 - i / num) * 0.2
            cb = new CANNON.Body({mass:1,shape:new CANNON.Sphere(r)})
            cb.position.set(p.x,p.y - i * 0.5,p.z)
            cb.mesh = new Mesh(Geom.sphere({radius:r,sgmt:8}),Materials.physics.chain)
            cb.keep = true
            cb.mesh.setShadow()
            world.scene.add(cb.mesh)
            cbs.push(cb)
            this.cannon.addBody(cb)
        }
        var list = _k_.list(cbs)
        for (i = 0; i < list.length; i++)
        {
            cb = list[i]
            if (i === 0)
            {
                polePivot = new CANNON.Vec3(0,5,0)
                ballPivot = new CANNON.Vec3(0,0,0)
                cstr = new CANNON.PointToPointConstraint(this.poleBody,polePivot,cbs[i],ballPivot)
                cstr.collideConnected = false
            }
            else
            {
                cstr = new CANNON.DistanceConstraint(cbs[i - 1],cbs[i],cbs[i - 1].shapes[0].radius + cbs[i].shapes[0].radius)
                cstr.collideConnected = false
            }
            this.cannon.addConstraint(cstr)
        }
    }

    Needle.prototype["simulate"] = function (scaledDelta, timeSum)
    {
        this.poleBody.position.copy(vec(this.poleBody.position).lerp(rts.centerHelper.position,0.2))
        return this.poleBody.quaternion.copy(rts.centerHelper.quaternion)
    }

    return Needle
})()

module.exports = Needle