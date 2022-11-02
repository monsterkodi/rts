// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}}

var CANNON, CannonDebugger, Physics

CANNON = require('cannon-es')
CannonDebugger = require('cannon-es-debugger')

Physics = (function ()
{
    function Physics ()
    {
        var constraint, geom, groundBody

        this.cannon = new CANNON.World({gravity:new CANNON.Vec3(0,0,-9)})
        this.cannonDebugger = new CannonDebugger(world.scene,this.cannon)
        groundBody = new CANNON.Body({type:CANNON.Body.STATIC,shape:new CANNON.Plane()})
        groundBody.position.z = -0.5
        this.cannon.addBody(groundBody)
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

    Physics.prototype["clear"] = function ()
    {
        var body, meshBodies

        meshBodies = this.cannon.bodies.filter(function (b)
        {
            return b.mesh && !b.keep
        })
        var list = _k_.list(meshBodies)
        for (var _72_17_ = 0; _72_17_ < list.length; _72_17_++)
        {
            body = list[_72_17_]
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
        delete body.mesh
        return this.cannon.removeBody(body)
    }

    Physics.prototype["simulate"] = function (scaledDelta, timeSum)
    {
        var b, p, q

        this.poleBody.position.copy(vec(this.poleBody.position).lerp(rts.centerHelper.position,0.2))
        this.poleBody.quaternion.copy(rts.centerHelper.quaternion)
        p = vec()
        q = new Quaternion
        var list = _k_.list(this.cannon.bodies)
        for (var _95_14_ = 0; _95_14_ < list.length; _95_14_++)
        {
            b = list[_95_14_]
            if (b.kinematic)
            {
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
        for (var _106_14_ = 0; _106_14_ < list1.length; _106_14_++)
        {
            b = list1[_106_14_]
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
        this.cannon.addBody(cb)
        cargo.body = cb
        return cb
    }

    Physics.prototype["addCar"] = function (car)
    {
        var cb, _146_31_

        this.addCargo((typeof car.takeCargo === "function" ? car.takeCargo() : undefined))
        cb = new CANNON.Body({mass:1,shape:new CANNON.Cylinder(1,1,3.5,8)})
        cb.shapeOrientations[0].setFromVectors(new CANNON.Vec3(0,1,0),new CANNON.Vec3(0,0,1))
        car.mesh.position.z += 0.5
        cb.quaternion.copy(car.mesh.quaternion)
        cb.position.copy(car.mesh.position)
        cb.mesh = car.mesh
        this.cannon.addBody(cb)
        car.body = cb
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

        var list = _k_.list(this.cannon.bodies)
        for (var _176_17_ = 0; _176_17_ < list.length; _176_17_++)
        {
            body = list[_176_17_]
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
        for (var _201_16_ = 0; _201_16_ < list.length; _201_16_++)
        {
            car = list[_201_16_]
            this.addCar(car)
        }
    }

    Physics.prototype["addChain"] = function ()
    {
        var ballPivot, cb, cbs, cstr, i, num, p, polePivot, r

        cbs = []
        num = 16
        for (var _223_17_ = i = 0, _223_21_ = num; (_223_17_ <= _223_21_ ? i < num : i > num); (_223_17_ <= _223_21_ ? ++i : --i))
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