// monsterkodi/kode 0.243.0

var _k_ = {min: function () { m = Infinity; for (a of arguments) { if (Array.isArray(a)) {m = _k_.min.apply(_k_.min,[m].concat(a))} else {n = parseFloat(a); if(!isNaN(n)){m = n < m ? n : m}}}; return m }, clamp: function (l,h,v) { var ll = Math.min(l,h), hh = Math.max(l,h); if (!_k_.isNum(v)) { v = ll }; if (v < ll) { v = ll }; if (v > hh) { v = hh }; if (!_k_.isNum(v)) { v = ll }; return v }, isNum: function (o) {return !isNaN(o) && !isNaN(parseFloat(o)) && (isFinite(o) || o === Infinity || o === -Infinity)}}

var ANIM_DURATION, Arm, CurveHelper

CurveHelper = require('../lib/curvehelper')
ANIM_DURATION = 20

Arm = (function ()
{
    function Arm (station)
    {
        var base, bone1, bone2, elbow, geom, hand, handtop, palm, piston, wrist

        this.station = station
    
        this["animate"] = this["animate"].bind(this)
        this["storageToDockingAnimation"] = this["storageToDockingAnimation"].bind(this)
        this["resetStorageAnimation"] = this["resetStorageAnimation"].bind(this)
        this["loadCargoToCar"] = this["loadCargoToCar"].bind(this)
        this["checkForStorageCargo"] = this["checkForStorageCargo"].bind(this)
        this["checkForLoadingToCar"] = this["checkForLoadingToCar"].bind(this)
        this["checkForUnloadingCar"] = this["checkForUnloadingCar"].bind(this)
        this["storeCargoInStorage"] = this["storeCargoInStorage"].bind(this)
        this["releaseWaitingCar"] = this["releaseWaitingCar"].bind(this)
        this["takeCargoFromCar"] = this["takeCargoFromCar"].bind(this)
        base = Geom.halfsphere({radius:1})
        bone1 = Geom.pill({radius:0.3,length:3})
        bone2 = Geom.pill({radius:0.3,length:3})
        elbow = Geom.sphere({radius:0.7})
        wrist = Geom.halfsphere({radius:0.6})
        hand = Geom.roundedFrame({size:[2.8,2.8,2.8],radius:0.4,pos:[0,0,-1.3]})
        handtop = Geom.quad({size:[2.2,2.2],normal:Vector.unitZ})
        palm = Geom.quad({size:[2.2,2.2],normal:Vector.minusZ,pos:[0,0,-0.3]})
        this.group = new Group
        this.baseMesh = new Mesh(base,Materials.station.central)
        this.baseMesh.setShadow()
        this.baseMesh.name = 'arm'
        this.group.add(this.baseMesh)
        this.bone = []
        this.bone[0] = new Mesh(bone1,Materials.station.central)
        this.bone[0].setShadow()
        this.group.add(this.bone[0])
        this.bone[1] = new Mesh(bone2,Materials.station.central)
        this.bone[1].setShadow()
        this.group.add(this.bone[1])
        this.wristMesh = new Mesh(wrist,Materials.station.central)
        this.wristMesh.setShadow()
        this.group.add(this.wristMesh)
        piston = Geom.cylinder({height:0.6,radius:0.3})
        piston.translate(0,0,0.4)
        this.wristPiston = new Mesh(piston,Materials.train.piston.clone())
        this.wristMesh.add(this.wristPiston)
        geom = Geom.merge(hand,palm)
        this.handMesh = new Mesh(geom,Materials.station.central)
        this.handMesh.setShadow()
        this.handMesh.add(new Mesh(handtop,Materials.station.side))
        this.group.add(this.handMesh)
        this.elbowMesh = new Mesh(elbow,Materials.station.central)
        this.elbowMesh.setShadow()
        this.group.add(this.elbowMesh)
        piston = Geom.cylinder({height:1.6,radius:0.4})
        piston.rotateX(deg2rad(90))
        this.elbowPiston = new Mesh(piston,Materials.train.piston.clone())
        this.elbowMesh.add(this.elbowPiston)
        this.curveHelper = new CurveHelper
        world.physics.addKinematicArm(this)
        this.startAnimation({duration:5,points:[vec(-6,0,1),vec(-6,0,1)]})
    }

    Arm.prototype["startUnloadingCar"] = function ()
    {
        this.waitingForCar = false
        return this.startAnimation({duration:ANIM_DURATION / 6,animEnd:this.takeCargoFromCar,points:[vec(-6,0,1),vec(-6,0,-2)]})
    }

    Arm.prototype["takeCargoFromCar"] = function ()
    {
        if (this.cargo = this.station.waitingCar.cargo)
        {
            this.handMesh.add(this.cargo.mesh)
            this.cargo.mesh.quaternion.identity()
            this.cargo.mesh.position.set(0,0,-1.3)
            return this.startAnimation({duration:ANIM_DURATION / 6,animEnd:this.releaseWaitingCar,points:[vec(-6,0,-2),vec(-6,0,1)]})
        }
        else
        {
            console.log('no cargo on waitingCar?')
            delete this.station.waitingCar
            this.waitingForCar = true
            return this.startAnimation({duration:ANIM_DURATION / 6,points:[vec(-6,0,-2),vec(-6,0,1)]})
        }
    }

    Arm.prototype["releaseWaitingCar"] = function ()
    {
        this.station.waitingCar.takeCargo()
        delete this.station.waitingCar
        return this.startAnimation({duration:ANIM_DURATION,animEnd:this.storeCargoInStorage,points:[vec(-6,0,1),vec(-6,0,3),vec(-6,-1,3.5),vec(-4,-4,3),vec(0,-5.5,2.5),vec(4,-4,3),vec(6,-1,3.5),vec(6,0,3),vec(6,0,1),vec(6,0,-1.05)]})
    }

    Arm.prototype["storeCargoInStorage"] = function ()
    {
        this.station.storage.storeCargo(this.cargo)
        delete this.cargo
        return this.storageToDockingAnimation(this.checkForUnloadingCar)
    }

    Arm.prototype["checkForUnloadingCar"] = function ()
    {
        if (this.station.waitingCar)
        {
            return this.startUnloadingCar()
        }
        else
        {
            return this.waitingForCar = true
        }
    }

    Arm.prototype["checkForLoadingToCar"] = function ()
    {
        if (this.station.waitingCar)
        {
            return this.startLoadingToCar()
        }
        else
        {
            return this.waitingForCar = true
        }
    }

    Arm.prototype["checkForStorageCargo"] = function ()
    {
        if (this.cargo = this.station.storage.hasCargo())
        {
            this.handMesh.add(this.cargo.mesh)
            this.cargo.mesh.quaternion.identity()
            this.cargo.mesh.position.set(0,0,-1.3)
            this.station.storage.cargoTaken()
            return this.storageToDockingAnimation(this.checkForLoadingToCar)
        }
    }

    Arm.prototype["startLoadingToCar"] = function ()
    {
        this.waitingForCar = false
        return this.startAnimation({duration:ANIM_DURATION / 6,animEnd:this.loadCargoToCar,points:[vec(-6,0,1),vec(-6,0,-2)]})
    }

    Arm.prototype["loadCargoToCar"] = function ()
    {
        this.station.waitingCar.setCargo(this.cargo)
        delete this.station.waitingCar
        delete this.cargo
        return this.startAnimation({duration:ANIM_DURATION / 6,animEnd:this.resetStorageAnimation,points:[vec(-6,0,-2),vec(-6,0,1)]})
    }

    Arm.prototype["resetStorageAnimation"] = function ()
    {
        return this.startAnimation({duration:ANIM_DURATION,animEnd:this.checkForStorageCargo,points:[vec(-6,0,1),vec(-6,0,3),vec(-6,-1,3.5),vec(-4,-4,3),vec(0,-5.5,2.5),vec(4,-4,3),vec(6,-1,3.5),vec(6,0,3),vec(6,0,1),vec(6,0,-1.05)]})
    }

    Arm.prototype["storageToDockingAnimation"] = function (animEnd)
    {
        return this.startAnimation({duration:ANIM_DURATION,animEnd:animEnd,points:[vec(6,0,-1.05),vec(6,0,1),vec(6,0,3),vec(6,1,3.5),vec(4,4,3),vec(0,5.5,2.5),vec(-4,4,3),vec(-6,1,3.5),vec(-6,0,3),vec(-6,0,1)]})
    }

    Arm.prototype["startAnimation"] = function (cfg)
    {
        var _204_37_

        world.removeAnimation(this.animate)
        this.animTime = 0
        this.animDuration = ((_204_37_=cfg.duration) != null ? _204_37_ : ANIM_DURATION)
        this.animEnd = cfg.animEnd
        this.handCurvePath = new CurvePath
        this.handCurvePath.add(new THREE.CatmullRomCurve3(cfg.points))
        this.curveHelper.setCurve(this.handCurvePath)
        return world.addAnimation(this.animate)
    }

    Arm.prototype["animate"] = function (delta, timeSum)
    {
        var animFactor, basePos, baseSphere, c, c2h, col, d, dx, dy, dz, elbowPos, o, r, ray, u, wristPos

        this.animTime += _k_.min(this.animDuration,delta)
        animFactor = _k_.clamp(0,1,this.animTime / this.animDuration)
        basePos = vec(this.baseMesh.position)
        wristPos = vec(this.handCurvePath.getPointAt(animFactor))
        this.handMesh.position.copy(wristPos)
        this.wristMesh.position.copy(wristPos)
        c2h = vec(wristPos).minus(basePos)
        c2h.z = 0
        dx = c2h.normalize()
        dz = Vector.unitZ
        dy = vec(dz).cross(dx)
        this.handMesh.quaternion.setFromRotationMatrix((new Matrix4).makeBasis(dx,dy,dz))
        this.wristMesh.quaternion.copy(this.handMesh.quaternion)
        dx = c2h.normalize()
        dz = Vector.unitZ
        dy = dz.crossed(dx)
        dx = dy.crossed(dz)
        this.baseMesh.quaternion.setFromRotationMatrix((new Matrix4).makeBasis(dx,dy,dz))
        this.elbowMesh.quaternion.copy(this.baseMesh.quaternion)
        o = Vector.midPoint(basePos,wristPos)
        d = basePos.to(wristPos).normalize()
        r = d.crossed(Vector.unitZ)
        u = r.crossed(d)
        ray = new Ray(o,u)
        baseSphere = new Sphere(basePos,4.5)
        elbowPos = vec()
        if (ray.intersectSphere(baseSphere,elbowPos))
        {
            this.elbowMesh.position.copy(elbowPos.minus(basePos))
            this.bone[0].position.copy(Vector.midPoint(elbowPos,basePos).sub(basePos))
            this.bone[0].quaternion.copy(Quaternion.unitVectors(Vector.unitZ,elbowPos.to(basePos).normalize()))
            this.bone[1].position.copy(Vector.midPoint(elbowPos,wristPos).sub(basePos))
            this.bone[1].quaternion.copy(Quaternion.unitVectors(Vector.unitZ,elbowPos.to(wristPos).normalize()))
        }
        c = _k_.clamp(0,1,Math.sin(this.animTime))
        col = this.handMesh.children[0].material.color
        this.elbowPiston.material.color.copy(col)
        this.wristPiston.material.color.copy(col)
        this.elbowPiston.material.emissive.setRGB(col.r * c,col.g * c,col.b * c)
        this.wristPiston.material.emissive.copy(this.elbowPiston.material.emissive)
        if (animFactor < 1)
        {
            return world.addAnimation(this.animate)
        }
        else if (this.animEnd)
        {
            return this.animEnd()
        }
    }

    return Arm
})()

module.exports = Arm