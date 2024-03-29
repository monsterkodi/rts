// monsterkodi/kode 0.257.0

var _k_

class Construct
{
    constructor ()
    {
        this.meshes = {}
    }

    init ()
    {
        this.initCargo()
        this.initEngine()
        this.initBoxcar()
        this.meshes.station = {}
        this.initArmbase()
        this.initDocking()
        return this.initStorage()
    }

    initCargo ()
    {
        var box, cargo

        box = new BoxGeometry(2,2,2)
        cargo = new Mesh(box,Materials.train.cargo)
        cargo.setShadow()
        return this.meshes.cargo = cargo
    }

    initArmbase ()
    {
        var baseMesh, frame, sideMesh, sides

        frame = Geom.roundedBox({size:[6,6,6],radius:0.8,pos:[0,0,2.5]})
        sides = Geom.roundedBoxSides({size:[6,6,6],radius:0.8,pos:[0,0,2.5]})
        baseMesh = new Mesh(frame,Materials.station.central)
        baseMesh.setShadow()
        sideMesh = new Mesh(sides,Materials.station.side)
        sideMesh.setShadow()
        baseMesh.add(sideMesh)
        return this.meshes.station.armbase = baseMesh
    }

    initDocking ()
    {
        var geom

        geom = Geom.roundedFrame({size:[6,6,6],radius:0.8,pos:[0,0,2.5]})
        this.meshes.station.docking = new Mesh(geom,Materials.station.central)
        return this.meshes.station.docking.setShadow()
    }

    initStorage ()
    {
        var geom

        geom = Geom.roundedBase({size:[6,6,0.8],radius:0.8,pos:[0,0,0]})
        this.meshes.station.storage = new Mesh(geom,Materials.station.central)
        return this.meshes.station.storage.setShadow()
    }

    initEngine ()
    {
        var body, cutm, cyl, geom, left, light, pill, piston, rail, right, seg, side, tail, wind

        seg = 16
        pill = Geom.pill({length:2,radius:1,sgmt:16})
        cutm = new BoxGeometry(3,1,1)
        cutm.translate(0,-0.5,0)
        body = Geom.subtract(pill,cutm)
        cyl = new CylinderGeometry(0.5,0.5,4,16,1)
        cyl.rotateZ(Math.PI / 2)
        body = Geom.subtract(body,cyl)
        wind = new BoxGeometry(1.5,0.5,0.5)
        wind.translate(0,0.5,1.6)
        side = new BoxGeometry(2,0.22,0.3)
        side.translate(0,0.65,1.05)
        wind = Geom.union(wind,side)
        geom = Geom.subtract(body,wind)
        rail = new BoxGeometry(1,1,8)
        rail.translate(0,-1,0)
        geom = Geom.subtract(geom,rail)
        this.meshes.engine = new Mesh(geom,Materials.train.body)
        this.meshes.engine.setShadow()
        geom = Geom.intersect(body,wind)
        piston = new CylinderGeometry(0.5,0.5,1.6,16,1)
        piston.rotateZ(Math.PI / 2)
        left = new CylinderGeometry(0.2,0.2,0.2,16,1,false,-Math.PI / 2,Math.PI)
        left.rotateX(-0.41)
        left.rotateZ(Math.PI / 4 - 0.1)
        left.translate(-0.554,0,0)
        right = new CylinderGeometry(0.2,0.2,0.2,16,1,false,-Math.PI / 2,Math.PI)
        right.rotateX(-0.41)
        right.rotateZ(-Math.PI / 4 + 0.1)
        right.translate(0.554,0,0)
        light = Geom.merge(left,right)
        light.rotateX(Math.PI / 2)
        light.translate(0,0.24,1.67)
        tail = new CylinderGeometry(0.25,0.25,0.05,16,1)
        tail.rotateX(Math.PI / 2)
        tail.translate(0,0,-2)
        this.meshes.engine.add(new Mesh(geom,Materials.train.window))
        this.meshes.engine.add(new Mesh(piston,Materials.train.piston))
        this.meshes.engine.add(new Mesh(light,Materials.train.light))
        return this.meshes.engine.add(new Mesh(tail,Materials.train.light))
    }

    initBoxcar ()
    {
        var body, box, cutm, cyl, geom, pill, rail, seg, tail, wind

        seg = 16
        pill = Geom.pill({length:2,radius:1,sgmt:16})
        cutm = new BoxGeometry(3,1,1)
        cutm.translate(0,-0.5,0)
        body = Geom.subtract(pill,cutm)
        cyl = new CylinderGeometry(0.5,0.5,4,16,1)
        cyl.rotateZ(Math.PI / 2)
        body = Geom.subtract(body,cyl)
        wind = new BoxGeometry(1.5,0.5,0.5)
        wind.translate(0,0.5,1.6)
        rail = new BoxGeometry(1,1,8)
        rail.translate(0,-1,0)
        geom = Geom.subtract(pill,rail)
        box = new BoxGeometry(2,1.5,2.7)
        box.translate(0,0.3,0)
        geom = Geom.subtract(geom,box)
        this.meshes.boxcar = new Mesh(geom,Materials.train.body)
        this.meshes.boxcar.setShadow()
        tail = new CylinderGeometry(0.25,0.25,0.05,16,1)
        tail.rotateX(Math.PI / 2)
        tail.translate(0,0,-2)
        return this.meshes.boxcar.add(new Mesh(tail,Materials.train.light))
    }
}

module.exports = Construct