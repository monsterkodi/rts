// monsterkodi/kode 0.257.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}}

var CANNON, CannonDebugger, Needle, Physics

CANNON = require('cannon-es')
CannonDebugger = require('cannon-es-debugger')
Needle = require('./needle')

Physics = (function ()
{
    function Physics ()
    {
        var constraint, groundBody

        this.cannon = new CANNON.World({gravity:new CANNON.Vec3(0,0,-9)})
        this.cannonDebugger = new CannonDebugger(world.scene,this.cannon)
        groundBody = new CANNON.Body({type:CANNON.Body.STATIC,shape:new CANNON.Plane()})
        groundBody.position.z = -0.5
        this.cannon.addBody(groundBody)
        this.centerNeedle = new Needle(this.cannon)
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
    }

    Physics.prototype["clear"] = function ()
    {
        var body, meshBodies

        meshBodies = this.cannon.bodies.filter(function (b)
        {
            return b.mesh && !b.keep
        })
        var list = _k_.list(meshBodies)
        for (var _60_17_ = 0; _60_17_ < list.length; _60_17_++)
        {
            body = list[_60_17_]
            this.removeBody(body)
        }
    }

    Physics.prototype["addBody"] = function (body)
    {
        return this.cannon.addBody(body)
    }

    Physics.prototype["removeBody"] = function (body)
    {
        body.mesh.removeFromParent()
        delete body.obj.body
        delete body.obj
        delete body.mesh
        return this.cannon.removeBody(body)
    }

    Physics.prototype["simulate"] = function (scaledDelta, timeSum)
    {
        var b, cnt, p, q

        this.centerNeedle.simulate(scaledDelta,timeSum)
        p = vec()
        q = new Quaternion
        cnt = 0
        var list = _k_.list(this.cannon.bodies)
        for (var _85_14_ = 0; _85_14_ < list.length; _85_14_++)
        {
            b = list[_85_14_]
            if (b.kinematic)
            {
                cnt++
                b.kinematic.getWorldPosition(p)
                b.kinematic.getWorldQuaternion(q)
                b.position.copy(p)
                b.quaternion.copy(q)
            }
        }
        this.cannon.step(1 / 60,scaledDelta,10)
        if (prefs.get('cannon'))
        {
            this.cannonDebugger.update()
        }
        var list1 = _k_.list(this.cannon.bodies)
        for (var _97_14_ = 0; _97_14_ < list1.length; _97_14_++)
        {
            b = list1[_97_14_]
            if (b.mesh)
            {
                b.mesh.position.copy(b.position)
                b.mesh.quaternion.copy(b.quaternion)
            }
        }
    }

    Physics.prototype["addCargo"] = function (cargo)
    {
        var cb, pos, quat

        if (!cargo)
        {
            return
        }
        quat = new Quaternion
        pos = vec()
        cargo.mesh.getWorldPosition(pos)
        cargo.mesh.getWorldQuaternion(quat)
        world.scene.add(cargo.mesh)
        cargo.mesh.position.copy(pos)
        cargo.mesh.quaternion.copy(quat)
        cargo.mesh.position.z += 2
        cb = new CANNON.Body({mass:1,shape:new CANNON.Box(new CANNON.Vec3(1,1,1))})
        cb.quaternion.copy(cargo.mesh.quaternion)
        cb.position.copy(cargo.mesh.position)
        cb.mesh = cargo.mesh
        cb.obj = cargo
        this.cannon.addBody(cb)
        cb.obj.body = cb
        return cb
    }

    Physics.prototype["addCar"] = function (car)
    {
        var cb, _138_31_

        this.addCargo((typeof car.takeCargo === "function" ? car.takeCargo() : undefined))
        cb = new CANNON.Body({mass:1,shape:new CANNON.Cylinder(1,1,3.5,8)})
        cb.shapeOrientations[0].setFromVectors(new CANNON.Vec3(0,1,0),new CANNON.Vec3(0,0,1))
        car.mesh.position.z += 0.5
        cb.quaternion.copy(car.mesh.quaternion)
        cb.position.copy(car.mesh.position)
        cb.mesh = car.mesh
        cb.obj = car
        this.cannon.addBody(cb)
        cb.obj.body = cb
        return cb
    }

    Physics.prototype["addKinematicCar"] = function (car)
    {
        var cb

        cb = new CANNON.Body({type:CANNON.Body.KINEMATIC,shape:new CANNON.Cylinder(1,1,3.5,8)})
        cb.shapeOrientations[0].setFromVectors(new CANNON.Vec3(0,1,0),new CANNON.Vec3(0,0,1))
        cb.quaternion.copy(car.mesh.quaternion)
        cb.position.copy(car.mesh.position)
        cb.kinematic = car.mesh
        this.cannon.addBody(cb)
        return cb
    }

    Physics.prototype["removeKinematicCar"] = function (car)
    {
        var body

        if (!car)
        {
            return
        }
        var list = _k_.list(this.cannon.bodies)
        for (var _169_17_ = 0; _169_17_ < list.length; _169_17_++)
        {
            body = list[_169_17_]
            if (body.kinematic === car.mesh)
            {
                this.cannon.removeBody(body)
                return
            }
        }
    }

    Physics.prototype["addKinematicArm"] = function (arm)
    {
        var cb, mesh

        cb = new CANNON.Body({type:CANNON.Body.KINEMATIC})
        cb.addShape(new CANNON.Box(new CANNON.Vec3(1.2,1.2,1.2)))
        cb.shapeOffsets[0].z = -1.2
        mesh = arm.handMesh
        cb.kinematic = mesh
        this.cannon.addBody(cb)
        return cb
    }

    Physics.prototype["addTrain"] = function (train)
    {
        var car

        if (train.cars[0].body)
        {
            return
        }
        var list = _k_.list(train.cars)
        for (var _194_16_ = 0; _194_16_ < list.length; _194_16_++)
        {
            car = list[_194_16_]
            this.addCar(car)
        }
    }

    Physics.prototype["addStation"] = function (station)
    {
        var cb

        cb = new CANNON.Body({type:CANNON.Body.STATIC})
        cb.addShape(new CANNON.Box(new CANNON.Vec3(3,3,3)))
        cb.shapeOffsets[0].z = 2.5
        cb.position.copy(station.group.position)
        return this.cannon.addBody(cb)
    }

    Physics.prototype["addStorage"] = function (storage)
    {
        var cb

        cb = new CANNON.Body({type:CANNON.Body.STATIC})
        cb.addShape(new CANNON.Box(new CANNON.Vec3(3,3,0.5)))
        storage.group.getWorldPosition(Vector.tmp)
        cb.position.copy(Vector.tmp)
        return this.cannon.addBody(cb)
    }

    return Physics
})()

module.exports = Physics