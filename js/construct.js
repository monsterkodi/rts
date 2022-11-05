// monsterkodi/kode 0.243.0

var _k_ = {profile: function (id) {_k_.hrtime ??= {}; _k_.hrtime[id] = process.hrtime.bigint()}, profilend: function (id) { var b = process.hrtime.bigint()-_k_.hrtime[id]; let f=1000n; for (let u of ['ns','μs','ms','s']) { if (u=='s' || b<f) { return console.log(id+' '+(1000n*b/f)+' '+u); } f*=1000n; }}}

class Construct
{
    constructor ()
    {
        this.meshes = {}
    }

    init ()
    {
        return this.initTrains()
    }

    initTrains ()
    {
        _k_.profile('trains')
        this.initEngine()
        this.initBoxcar()
        return _k_.profilend('trains')
    }

    initEngine ()
    {
        var body, cutm, cyl, geom, left, light, offset, pill, piston, rail, right, seg, side, tail, wind

        seg = 16
        pill = Geom.pill(2,1,16)
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
        offset = 0.85
        rail = new BoxGeometry(1,1,8)
        rail.translate(0,-1,0)
        geom = Geom.subtract(geom,rail)
        geom.translate(0,offset,0)
        this.meshes.engine = new Mesh(geom,Materials.train.body)
        this.meshes.engine.receiveShadow = true
        this.meshes.engine.castShadow = true
        geom = Geom.intersect(body,wind)
        geom.translate(0,offset,0)
        piston = new CylinderGeometry(0.5,0.5,1.6,16,1)
        piston.rotateZ(Math.PI / 2)
        piston.translate(0,offset,0)
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
        light.translate(0,offset + 0.24,1.67)
        tail = new CylinderGeometry(0.25,0.25,0.05,16,1)
        tail.rotateX(Math.PI / 2)
        tail.translate(0,offset,-2)
        this.meshes.engine.add(new Mesh(geom,Materials.train.window))
        this.meshes.engine.add(new Mesh(piston,Materials.train.piston))
        this.meshes.engine.add(new Mesh(light,Materials.train.light))
        return this.meshes.engine.add(new Mesh(tail,Materials.train.light))
    }

    initBoxcar ()
    {
        var body, box, boxMesh, cutm, cyl, geom, offset, pill, rail, seg, tail, wind

        seg = 16
        pill = Geom.pill(2,1,16)
        cutm = new BoxGeometry(3,1,1)
        cutm.translate(0,-0.5,0)
        body = Geom.subtract(pill,cutm)
        cyl = new CylinderGeometry(0.5,0.5,4,16,1)
        cyl.rotateZ(Math.PI / 2)
        body = Geom.subtract(body,cyl)
        wind = new BoxGeometry(1.5,0.5,0.5)
        wind.translate(0,0.5,1.6)
        offset = 0.85
        rail = new BoxGeometry(1,1,8)
        rail.translate(0,-1,0)
        geom = Geom.subtract(pill,rail)
        box = new BoxGeometry(2,1.5,2.7)
        box.translate(0,0.3,0)
        geom = Geom.subtract(geom,box)
        geom.translate(0,offset,0)
        this.meshes.boxcar = new Mesh(geom,Materials.train.body)
        this.meshes.boxcar.receiveShadow = true
        this.meshes.boxcar.castShadow = true
        box = new BoxGeometry(2,2,2)
        box.translate(0,offset + 0.9,0)
        boxMesh = new Mesh(box,Materials.train.cargo)
        boxMesh.receiveShadow = true
        boxMesh.castShadow = true
        this.meshes.boxcar.add(boxMesh)
        tail = new CylinderGeometry(0.25,0.25,0.05,16,1)
        tail.rotateX(Math.PI / 2)
        tail.translate(0,offset,-2)
        return this.meshes.boxcar.add(new Mesh(tail,Materials.train.light))
    }
}

module.exports = Construct