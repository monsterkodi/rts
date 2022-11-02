// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}}

var CANNON, CannonDebugger, Physics

CANNON = require('cannon-es')
CannonDebugger = require('cannon-es-debugger')

Physics = (function ()
{
    function Physics ()
    {
        var constraint, groundBody

        this["postLoop"] = this["postLoop"].bind(this)
        this.cannon = new CANNON.World({gravity:new CANNON.Vec3(0,0,-9)})
        this.cannonDebugger = new CannonDebugger(world.scene,this.cannon)
        this.bodies = []
        groundBody = new CANNON.Body({type:CANNON.Body.STATIC,shape:new CANNON.Plane()})
        groundBody.position.z = -0.5
        this.cannon.addBody(groundBody)
        this.poleBody = new CANNON.Body({type:CANNON.Body.KINEMATIC,shape:new CANNON.Cylinder(0.1,0.1,5,8)})
        this.poleBody.addShape(new CANNON.Sphere(0.3))
        this.poleBody.shapeOffsets[1].y = 2.65
        this.poleBody.position.set(0,0,5)
        this.poleBody.quaternion.copy(Quaternion.unitVectors(Vector.unitY,Vector.unitZ))
        this.cannon.addBody(this.poleBody)
        if (false)
        {
            this.cylinderBody1 = new CANNON.Body({mass:0.1,shape:new CANNON.Cylinder(0.8,1,4,16)})
            this.cylinderBody1.position.set(-5,0,5)
            this.cylinderBody1.shapeOrientations[0].setFromVectors(new CANNON.Vec3(0,1,0),new CANNON.Vec3(0,0,1))
            this.cannon.addBody(this.cylinderBody1)
            this.cylinderBody2 = new CANNON.Body({mass:0.1,shape:new CANNON.Cylinder(0.5,1,4,16)})
            this.cylinderBody2.position.set(5,0,5)
            this.cylinderBody2.shapeOrientations[0].setFromVectors(new CANNON.Vec3(0,1,0),new CANNON.Vec3(0,0,1))
            this.cannon.addBody(this.cylinderBody2)
            constraint = new CANNON.ConeTwistConstraint(this.cylinderBody1,this.cylinderBody2,{collideConnected:true,wakeUpBodies:true,axisA:new CANNON.Vec3(0,0,1),pivotA:new CANNON.Vec3(0,0,3),axisB:new CANNON.Vec3(0,0,-1),pivotB:new CANNON.Vec3(0,0,3),maxForce:10,twistAngle:deg2rad(180)})
            this.cannon.addConstraint(constraint)
        }
        this.addChain()
    }

    Physics.prototype["simulate"] = function (scaledDelta, timeSum)
    {
        var target

        target = vec(Vector.unitY)
        target.applyQuaternion(rts.centerHelper.quaternion)
        target.scale(2.5)
        target.add(rts.centerHelper.position)
        this.poleBody.position.copy(vec(this.poleBody.position).lerp(target,0.2))
        this.poleBody.quaternion.copy(rts.centerHelper.quaternion)
        this.cannon.fixedStep()
        if (prefs.get('cannon'))
        {
            this.cannonDebugger.update()
        }
        return this.postLoop()
    }

    Physics.prototype["postLoop"] = function ()
    {
        var b

        var list = _k_.list(this.bodies)
        for (var _81_14_ = 0; _81_14_ < list.length; _81_14_++)
        {
            b = list[_81_14_]
            b.mesh.position.copy(b.position)
            b.mesh.quaternion.copy(b.quaternion)
        }
    }

    Physics.prototype["addCargo"] = function (cargo)
    {
        var cb, pos, quat

        if (!cargo)
        {
            return
        }
        cb = new CANNON.Body({mass:1,shape:new CANNON.Box(new CANNON.Vec3(1,1,1))})
        pos = vec()
        quat = new Quaternion
        cargo.mesh.getWorldQuaternion(quat)
        cargo.mesh.getWorldPosition(pos)
        cb.position.copy(pos)
        cb.quaternion.copy(quat)
        world.scene.add(cargo.mesh)
        cb.mesh = cargo.mesh
        this.cannon.addBody(cb)
        this.bodies.push(cb)
        cargo.body = cb
        return cb
    }

    Physics.prototype["addCar"] = function (car)
    {
        var cb, p, _104_31_

        this.addCargo((typeof car.takeCargo === "function" ? car.takeCargo() : undefined))
        cb = new CANNON.Body({mass:1,shape:new CANNON.Cylinder(1,1,3.5,8)})
        cb.shapeOrientations[0].setFromVectors(new CANNON.Vec3(0,1,0),new CANNON.Vec3(0,0,1))
        p = vec()
        car.mesh.getWorldPosition(p)
        cb.position.copy(p)
        cb.quaternion.copy(car.mesh.quaternion)
        cb.mesh = car.mesh
        this.cannon.addBody(cb)
        this.bodies.push(cb)
        car.body = cb
        return cb
    }

    Physics.prototype["addTrain"] = function (train)
    {
        var car, i

        if (train.cars[0].body)
        {
            return
        }
        var list = _k_.list(train.cars)
        for (var _122_16_ = 0; _122_16_ < list.length; _122_16_++)
        {
            car = list[_122_16_]
            this.addCar(car)
        }
        return
        var list1 = _k_.list(train.cars)
        for (i = 0; i < list1.length; i++)
        {
            car = list1[i]
            if (i > 0)
            {
                this.cannon.addConstraint(new CANNON.ConeTwistConstraint(train.cars[i - 1].body,car.body,{axisA:new CANNON.Vec3(0,0,1),pivotA:new CANNON.Vec3(0,0,3),axisB:new CANNON.Vec3(0,0,-1),pivotB:new CANNON.Vec3(0,0,3),twistAngle:deg2rad(90)}))
            }
        }
    }

    Physics.prototype["addChain"] = function ()
    {
        var cb, cbs, cstr, i, num, p, r

        cbs = []
        num = 24
        for (var _140_17_ = i = 0, _140_21_ = num; (_140_17_ <= _140_21_ ? i < num : i > num); (_140_17_ <= _140_21_ ? ++i : --i))
        {
            p = this.poleBody.position
            r = 0.25 + (1 - i / num) * 0.2
            cb = new CANNON.Body({mass:1,shape:new CANNON.Sphere(r)})
            cb.position.set(p.x,p.y - i * 0.5,p.z)
            cb.mesh = new Mesh(Geom.sphere({radius:r,sgmt:8}),Materials.physics.chain)
            cb.mesh.setShadow()
            world.scene.add(cb.mesh)
            cbs.push(cb)
            this.bodies.push(cb)
            this.cannon.addBody(cb)
        }
        var list = _k_.list(cbs)
        for (i = 0; i < list.length; i++)
        {
            cb = list[i]
            if (i === 0)
            {
                cstr = new CANNON.DistanceConstraint(this.poleBody,cbs[i],1)
            }
            else
            {
                cstr = new CANNON.DistanceConstraint(cbs[i - 1],cbs[i],cbs[i - 1].shapes[0].radius + cbs[i].shapes[0].radius)
            }
            cstr.collideConnected = false
            this.cannon.addConstraint(cstr)
        }
    }

    return Physics
})()

module.exports = Physics