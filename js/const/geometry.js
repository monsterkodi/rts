// monsterkodi/kode 0.243.0

var _k_ = {isNum: function (o) {return !isNaN(o) && !isNaN(parseFloat(o)) && (isFinite(o) || o === Infinity || o === -Infinity)}}

var CSG, geomMerge

CSG = require("../lib/csg")
geomMerge = require("../lib/merge")
class Geometry
{
    static union (a, b)
    {
        return CSG.toGeometry(CSG.fromGeometry(a).union(CSG.fromGeometry(b)))
    }

    static subtract (a, b)
    {
        return CSG.toGeometry(CSG.fromGeometry(a).subtract(CSG.fromGeometry(b)))
    }

    static intersect (a, b)
    {
        return CSG.toGeometry(CSG.fromGeometry(a).intersect(CSG.fromGeometry(b)))
    }

    static merge ()
    {
        if (arguments.length === 1 && arguments[0] instanceof Array)
        {
            return geomMerge(arguments[0])
        }
        else
        {
            return geomMerge.apply(null,[arguments])
        }
    }

    static test ()
    {
        return this.subtract(this.box(),this.box(0.5,0.5))
    }

    static box (cfg = {})
    {
        var geom, p, s, x, y, z, _35_19_, _44_27_, _45_27_, _46_27_

        if ((cfg.size != null))
        {
            if (_k_.isNum(cfg.size))
            {
                x = y = z = cfg.size
            }
            else
            {
                s = vec(cfg.size)
                x = s.x
                y = s.y
                z = s.z
            }
        }
        else
        {
            x = ((_44_27_=cfg.width) != null ? _44_27_ : 1)
            y = ((_45_27_=cfg.depth) != null ? _45_27_ : 1)
            z = ((_46_27_=cfg.height) != null ? _46_27_ : 1)
        }
        geom = new BoxGeometry(x,y,z)
        if (cfg.pos)
        {
            p = vec(cfg.pos)
            geom.translate(p.x,p.y,p.z)
        }
        return geom
    }

    static sphere (cfg = {})
    {
        var geom, p, radius, sgmt, _64_28_, _65_26_

        radius = ((_64_28_=cfg.radius) != null ? _64_28_ : 1)
        sgmt = ((_65_26_=cfg.sgmt) != null ? _65_26_ : 16)
        geom = new SphereGeometry(radius,sgmt,sgmt)
        if (cfg.pos)
        {
            p = vec(cfg.pos)
            geom.translate(p.x,p.y,p.z)
        }
        return geom
    }

    static halfsphere (cfg = {})
    {
        var geom, p, radius, sgmt, _77_28_, _78_26_

        radius = ((_77_28_=cfg.radius) != null ? _77_28_ : 1)
        sgmt = ((_78_26_=cfg.sgmt) != null ? _78_26_ : 16)
        geom = new SphereGeometry(radius,sgmt,sgmt,0,2 * Math.PI / 2,0,Math.PI)
        if (cfg.dir)
        {
            geom.applyQuaternion(Quaternion.unitVectors(Vector.unitZ,cfg.dir))
        }
        if (cfg.pos)
        {
            p = vec(cfg.pos)
            geom.translate(p.x,p.y,p.z)
        }
        return geom
    }

    static cylinder (cfg = {})
    {
        var geom, height, p, radius, sgmt, _100_28_, _101_26_, _99_28_

        height = ((_99_28_=cfg.height) != null ? _99_28_ : 1)
        radius = ((_100_28_=cfg.radius) != null ? _100_28_ : 0.5)
        sgmt = ((_101_26_=cfg.sgmt) != null ? _101_26_ : 24)
        geom = new CylinderGeometry(radius,radius,height,sgmt)
        if (cfg.dir)
        {
            geom.applyQuaternion(Quaternion.unitVectors(Vector.unitY,cfg.dir))
        }
        else
        {
            geom.rotateX(Math.PI / 2)
        }
        if (cfg.pos)
        {
            p = vec(cfg.pos)
            geom.translate(p.x,p.y,p.z)
        }
        return geom
    }

    static cylindonut (height = 1, outerRadius = 1, innerRadius = outerRadius / 2, sgmt = 24)
    {
        var geom, inner

        geom = this.cylinder({height:height,radius:outerRadius,sgmt:sgmt})
        inner = this.cylinder({height:height,radius:innerRadius,sgmt:sgmt})
        geom = this.subtract(geom,inner)
        return geom
    }

    static pill (cfg = {})
    {
        var bot, geom, l, mid, p, r, s, top, _137_23_, _138_23_, _139_21_

        l = ((_137_23_=cfg.length) != null ? _137_23_ : 1)
        r = ((_138_23_=cfg.radius) != null ? _138_23_ : 0.5)
        s = ((_139_21_=cfg.sgmt) != null ? _139_21_ : 8)
        top = new SphereGeometry(r,s,s / 2,0,2 * Math.PI,0,Math.PI / 2)
        top.translate(0,l / 2,0)
        mid = new CylinderGeometry(r,r,l,s,1,true)
        bot = new SphereGeometry(r,s,s / 2,0,2 * Math.PI,Math.PI / 2,Math.PI / 2)
        bot.translate(0,-l / 2,0)
        geom = this.merge(top,mid,bot)
        geom.rotateX(Math.PI / 2)
        if (cfg.dir)
        {
            geom.applyQuaternion(Quaternion.unitVectors(Vector.unitZ,cfg.dir))
        }
        if (cfg.pos)
        {
            p = vec(cfg.pos)
            geom.translate(p.x,p.y,p.z)
        }
        return geom
    }

    static cylbox (cfg = {})
    {
        var box, geom, h, head, l, p, r, s, tail, _162_23_, _163_23_, _164_23_, _165_21_

        l = ((_162_23_=cfg.length) != null ? _162_23_ : 1)
        h = ((_163_23_=cfg.height) != null ? _163_23_ : 1)
        r = ((_164_23_=cfg.radius) != null ? _164_23_ : 0.5)
        s = ((_165_21_=cfg.sgmt) != null ? _165_21_ : 16)
        head = new CylinderGeometry(r,r,h,s,1,false,deg2rad(-90),deg2rad(180))
        head.translate(0,0,(l - 2 * r) / 2)
        box = Geom.box({size:[2 * r,h,l - 2 * r]})
        tail = new CylinderGeometry(r,r,h,s,1,false,deg2rad(90),deg2rad(180))
        tail.translate(0,0,-(l - 2 * r) / 2)
        geom = this.merge(box,head,tail)
        if (cfg.dir)
        {
            geom.applyQuaternion(Quaternion.unitVectors(Vector.unitZ,cfg.dir))
        }
        if (cfg.pos)
        {
            p = vec(cfg.pos)
            geom.translate(p.x,p.y,p.z)
        }
        return geom
    }

    static quad (cfg = {})
    {
        var geom, normal, p, sz, _198_28_

        sz = (cfg.size ? vec(cfg.size) : vec(1,1))
        normal = ((_198_28_=cfg.normal) != null ? _198_28_ : Vector.unitZ)
        geom = new PlaneGeometry(sz.x,sz.y)
        geom.applyQuaternion(Quaternion.unitVectors(Vector.unitZ,normal))
        if (cfg.pos)
        {
            p = vec(cfg.pos)
            geom.translate(p.x,p.y,p.z)
        }
        return geom
    }

    static corner (cfg = {})
    {
        var geom, matrix, p, radius, rx, ry, rz, sgmt, _217_29_, _218_29_, _219_29_, _220_28_, _221_26_

        rx = deg2rad(((_217_29_=cfg.rx) != null ? _217_29_ : 0))
        ry = deg2rad(((_218_29_=cfg.ry) != null ? _218_29_ : 0))
        rz = deg2rad(((_219_29_=cfg.rz) != null ? _219_29_ : 0))
        radius = ((_220_28_=cfg.radius) != null ? _220_28_ : 1)
        sgmt = ((_221_26_=cfg.sgmt) != null ? _221_26_ : 8)
        geom = new SphereGeometry(radius,sgmt,sgmt,0,Math.PI / 2,0,Math.PI / 2)
        geom.rotateX(Math.PI / 2)
        geom.rotateZ(Math.PI)
        matrix = new THREE.Matrix4
        matrix.makeRotationFromEuler(new THREE.Euler(rx,ry,rz))
        geom.applyMatrix4(matrix)
        if (cfg.pos)
        {
            p = vec(cfg.pos)
            geom.translate(p.x,p.y,p.z)
        }
        return geom
    }

    static piecap (cfg = {})
    {
        var geom, matrix, p, radius, rx, ry, rz, sgmt, _245_29_, _246_29_, _247_29_, _248_28_, _249_26_

        rx = deg2rad(((_245_29_=cfg.rx) != null ? _245_29_ : 0))
        ry = deg2rad(((_246_29_=cfg.ry) != null ? _246_29_ : 0))
        rz = deg2rad(((_247_29_=cfg.rz) != null ? _247_29_ : 0))
        radius = ((_248_28_=cfg.radius) != null ? _248_28_ : 1)
        sgmt = ((_249_26_=cfg.sgmt) != null ? _249_26_ : 8)
        geom = new CircleGeometry(radius,sgmt,0,Math.PI / 2)
        matrix = new THREE.Matrix4
        matrix.makeRotationFromEuler(new THREE.Euler(rx,ry,rz))
        geom.applyMatrix4(matrix)
        if (cfg.pos)
        {
            p = vec(cfg.pos)
            geom.translate(p.x,p.y,p.z)
        }
        return geom
    }

    static cylslice (cfg = {})
    {
        var dir, dirq, geom, length, p, radius, sgmt, start, _271_27_, _272_27_, _273_28_, _274_28_, _275_26_

        dir = ((_271_27_=cfg.dir) != null ? _271_27_ : Vector.unitZ)
        start = ((_272_27_=cfg.start) != null ? _272_27_ : Vector.unitX)
        radius = ((_273_28_=cfg.radius) != null ? _273_28_ : 0.5)
        length = ((_274_28_=cfg.length) != null ? _274_28_ : 1)
        sgmt = ((_275_26_=cfg.sgmt) != null ? _275_26_ : 8)
        geom = new CylinderGeometry(radius,radius,length,sgmt,1,true,0,Math.PI / 2)
        dirq = Quaternion.unitVectors(Vector.unitY,dir)
        geom.applyQuaternion(dirq)
        geom.applyQuaternion(Quaternion.unitVectors(Vector.unitX.clone().applyQuaternion(dirq),start))
        if (cfg.pos)
        {
            p = vec(cfg.pos)
            geom.translate(p.x,p.y,p.z)
        }
        return geom
    }

    static pie (cfg = {})
    {
        var cylnd, dir, geom, length, matrix, p, radius, sgmt, side1, side2, start, _296_27_, _297_27_, _298_28_, _299_28_, _300_26_

        dir = ((_296_27_=cfg.dir) != null ? _296_27_ : Vector.unitX)
        start = ((_297_27_=cfg.start) != null ? _297_27_ : Vector.unitY)
        radius = ((_298_28_=cfg.radius) != null ? _298_28_ : 0.5)
        length = ((_299_28_=cfg.length) != null ? _299_28_ : 1)
        sgmt = ((_300_26_=cfg.sgmt) != null ? _300_26_ : 8)
        side1 = this.quad({size:[length,radius],normal:Vector.minusY,pos:[0,0,radius / 2]})
        side2 = this.quad({size:[length,radius],normal:Vector.minusZ,pos:[0,radius / 2,0]})
        cylnd = new CylinderGeometry(radius,radius,length,sgmt,1,true,0,Math.PI / 2)
        cylnd.rotateZ(deg2rad(90))
        geom = this.merge(side1,side2,cylnd)
        matrix = new THREE.Matrix4
        matrix.makeBasis(dir,start,dir.crossed(start))
        geom.applyMatrix4(matrix)
        if (cfg.pos)
        {
            p = vec(cfg.pos)
            geom.translate(p.x,p.y,p.z)
        }
        return geom
    }

    static roundedBox (cfg = {})
    {
        var bb, botfr, cr, fb, frame, geom, p, sz, _328_24_

        cr = ((_328_24_=cfg.radius) != null ? _328_24_ : 0.2)
        sz = (cfg.size ? vec(cfg.size) : vec(1,1,1))
        frame = this.roundedFrame(cfg)
        fb = this.pie({radius:cr,dir:Vector.unitX,start:Vector.minusZ,length:sz.x - cr * 2,pos:[0,sz.y / 2 - cr,-sz.z / 2 + cr]})
        bb = this.pie({radius:cr,dir:Vector.minusX,start:Vector.minusZ,length:sz.x - cr * 2,pos:[0,-sz.y / 2 + cr,-sz.z / 2 + cr]})
        botfr = this.merge(fb,bb)
        if (cfg.pos)
        {
            p = vec(cfg.pos)
            botfr.translate(p.x,p.y,p.z)
        }
        return geom = this.merge(frame,botfr)
    }

    static roundedBoxSides (cfg = {})
    {
        var bs, cr, ds, fs, geom, ls, p, rs, sz, us, _346_24_

        cr = ((_346_24_=cfg.radius) != null ? _346_24_ : 0.2)
        sz = (cfg.size ? vec(cfg.size) : vec(1,1,1))
        rs = this.quad({size:[sz.z - cr * 2,sz.y - cr * 2],normal:Vector.unitX,pos:[sz.x / 2 - cr / 2,0,0]})
        ls = this.quad({size:[sz.z - cr * 2,sz.y - cr * 2],normal:Vector.minusX,pos:[-sz.x / 2 + cr / 2,0,0]})
        fs = this.quad({size:[sz.x - cr * 2,sz.z - cr * 2],normal:Vector.unitY,pos:[0,sz.y / 2 - cr / 2,0]})
        bs = this.quad({size:[sz.x - cr * 2,sz.z - cr * 2],normal:Vector.minusY,pos:[0,-sz.y / 2 + cr / 2,0]})
        ds = this.quad({size:[sz.x - cr * 2,sz.y - cr * 2],normal:Vector.minusZ,pos:[0,0,-sz.z / 2 + cr / 2]})
        us = this.quad({size:[sz.x - cr * 2,sz.y - cr * 2],normal:Vector.unitZ,pos:[0,0,sz.z / 2 - cr / 2]})
        geom = this.merge(rs,ls,fs,bs,ds,us)
        if (cfg.pos)
        {
            p = vec(cfg.pos)
            geom.translate(p.x,p.y,p.z)
        }
        return geom
    }

    static roundedFrame (cfg = {})
    {
        var box, bt, caps, corns, cr, frame, ft, lb, lbb, lbc, lbm, lbt, lfb, lfc, lfm, lft, lt, p, rb, rbb, rbc, rbm, rbt, rfb, rfc, rfm, rft, rt, sz, _372_24_

        cr = ((_372_24_=cfg.radius) != null ? _372_24_ : 0.2)
        sz = (cfg.size ? vec(cfg.size) : vec(1,1,1))
        ft = this.pie({radius:cr,dir:Vector.minusX,start:Vector.unitZ,length:sz.x - cr * 2,pos:[0,sz.y / 2 - cr,sz.z / 2 - cr]})
        bt = this.pie({radius:cr,dir:Vector.unitX,start:Vector.unitZ,length:sz.x - cr * 2,pos:[0,-sz.y / 2 + cr,sz.z / 2 - cr]})
        lt = this.pie({radius:cr,dir:Vector.minusY,start:Vector.unitZ,length:sz.y - cr * 2,pos:[-sz.x / 2 + cr,0,sz.z / 2 - cr]})
        rt = this.pie({radius:cr,dir:Vector.unitY,start:Vector.unitZ,length:sz.y - cr * 2,pos:[sz.x / 2 - cr,0,sz.z / 2 - cr]})
        lfm = this.pie({radius:cr,dir:Vector.unitZ,start:Vector.unitY,length:sz.z - cr * 2,pos:[-sz.x / 2 + cr,sz.y / 2 - cr,0]})
        lbm = this.pie({radius:cr,dir:Vector.minusZ,start:Vector.minusY,length:sz.z - cr * 2,pos:[-sz.x / 2 + cr,-sz.y / 2 + cr,0]})
        rfm = this.pie({radius:cr,dir:Vector.unitZ,start:Vector.unitX,length:sz.z - cr * 2,pos:[sz.x / 2 - cr,sz.y / 2 - cr,0]})
        rbm = this.pie({radius:cr,dir:Vector.minusZ,start:Vector.unitX,length:sz.z - cr * 2,pos:[sz.x / 2 - cr,-sz.y / 2 + cr,0]})
        lb = this.pie({radius:cr,dir:Vector.unitY,start:Vector.minusZ,length:sz.y - cr * 2,pos:[-sz.x / 2 + cr,0,-sz.z / 2 + cr]})
        rb = this.pie({radius:cr,dir:Vector.minusY,start:Vector.minusZ,length:sz.y - cr * 2,pos:[sz.x / 2 - cr,0,-sz.z / 2 + cr]})
        rft = this.corner({radius:cr,rx:0,ry:0,rz:0,pos:[sz.x / 2 - cr,sz.y / 2 - cr,sz.z / 2 - cr]})
        lft = this.corner({radius:cr,rx:0,ry:0,rz:90,pos:[-sz.x / 2 + cr,sz.y / 2 - cr,sz.z / 2 - cr]})
        rfb = this.corner({radius:cr,rx:0,ry:180,rz:90,pos:[sz.x / 2 - cr,sz.y / 2 - cr,-sz.z / 2 + cr]})
        lfb = this.corner({radius:cr,rx:0,ry:180,rz:0,pos:[-sz.x / 2 + cr,sz.y / 2 - cr,-sz.z / 2 + cr]})
        rbt = this.corner({radius:cr,rx:0,ry:0,rz:-90,pos:[sz.x / 2 - cr,-sz.y / 2 + cr,sz.z / 2 - cr]})
        lbt = this.corner({radius:cr,rx:0,ry:0,rz:180,pos:[-sz.x / 2 + cr,-sz.y / 2 + cr,sz.z / 2 - cr]})
        rbb = this.corner({radius:cr,rx:0,ry:180,rz:180,pos:[sz.x / 2 - cr,-sz.y / 2 + cr,-sz.z / 2 + cr]})
        lbb = this.corner({radius:cr,rx:0,ry:180,rz:-90,pos:[-sz.x / 2 + cr,-sz.y / 2 + cr,-sz.z / 2 + cr]})
        lfc = this.piecap({radius:cr,segs:8,pos:[-sz.x / 2 + cr,sz.y / 2 - cr,-sz.z / 2 + cr],ry:90})
        rfc = this.piecap({radius:cr,segs:8,pos:[sz.x / 2 - cr,sz.y / 2 - cr,-sz.z / 2 + cr],rz:90,ry:-90})
        lbc = this.piecap({radius:cr,segs:8,pos:[-sz.x / 2 + cr,-sz.y / 2 + cr,-sz.z / 2 + cr],rz:-90,ry:90})
        rbc = this.piecap({radius:cr,segs:8,pos:[sz.x / 2 - cr,-sz.y / 2 + cr,-sz.z / 2 + cr],rz:180,ry:-90})
        corns = this.merge(rft,lft,rbt,lbt,rfb,lfb,rbb,lbb)
        frame = this.merge(ft,bt,lt,rt,lfm,lbm,rfm,rbm,lb,rb)
        caps = this.merge(lfc,rfc,lbc,rbc)
        box = this.merge(frame,corns,caps)
        if (cfg.pos)
        {
            p = vec(cfg.pos)
            box.translate(p.x,p.y,p.z)
        }
        return box
    }

    static roundedBase (cfg = {})
    {
        var base, bb, caps, corns, cr, fb, frame, lb, lbb, lbc, lfb, lfc, p, rb, rbb, rbc, rfb, rfc, sz, _426_24_

        cr = ((_426_24_=cfg.radius) != null ? _426_24_ : 0.2)
        sz = (cfg.size ? vec(cfg.size) : vec(1,1,cr))
        lb = this.pie({radius:cr,dir:Vector.unitY,start:Vector.minusZ,length:sz.y - cr * 2,pos:[-sz.x / 2 + cr,0,-sz.z / 2 + cr]})
        rb = this.pie({radius:cr,dir:Vector.minusY,start:Vector.minusZ,length:sz.y - cr * 2,pos:[sz.x / 2 - cr,0,-sz.z / 2 + cr]})
        fb = this.pie({radius:cr,dir:Vector.unitX,start:Vector.minusZ,length:sz.x - cr * 2,pos:[0,sz.y / 2 - cr,-sz.z / 2 + cr]})
        bb = this.pie({radius:cr,dir:Vector.minusX,start:Vector.minusZ,length:sz.x - cr * 2,pos:[0,-sz.y / 2 + cr,-sz.z / 2 + cr]})
        rfb = this.corner({radius:cr,rx:0,ry:180,rz:90,pos:[sz.x / 2 - cr,sz.y / 2 - cr,-sz.z / 2 + cr]})
        lfb = this.corner({radius:cr,rx:0,ry:180,rz:0,pos:[-sz.x / 2 + cr,sz.y / 2 - cr,-sz.z / 2 + cr]})
        rbb = this.corner({radius:cr,rx:0,ry:180,rz:180,pos:[sz.x / 2 - cr,-sz.y / 2 + cr,-sz.z / 2 + cr]})
        lbb = this.corner({radius:cr,rx:0,ry:180,rz:-90,pos:[-sz.x / 2 + cr,-sz.y / 2 + cr,-sz.z / 2 + cr]})
        rfc = this.piecap({radius:cr,segs:8,pos:[sz.x / 2 - cr,sz.y / 2 - cr,-sz.z / 2 + cr]})
        lfc = this.piecap({radius:cr,segs:8,pos:[-sz.x / 2 + cr,sz.y / 2 - cr,-sz.z / 2 + cr],rz:90})
        lbc = this.piecap({radius:cr,segs:8,pos:[-sz.x / 2 + cr,-sz.y / 2 + cr,-sz.z / 2 + cr],rz:180})
        rbc = this.piecap({radius:cr,segs:8,pos:[sz.x / 2 - cr,-sz.y / 2 + cr,-sz.z / 2 + cr],rz:-90})
        corns = this.merge(rfb,lfb,rbb,lbb)
        frame = this.merge(lb,rb,fb,bb)
        caps = this.merge(lfc,rfc,lbc,rbc)
        base = this.merge(frame,corns,caps)
        if (cfg.pos)
        {
            p = vec(cfg.pos)
            base.translate(p.x,p.y,p.z)
        }
        return base
    }

    static triangle (cfg = {})
    {
        var geom, p, s, vertices, x, xh, y, yh, z, zh, _463_19_, _472_27_, _473_27_, _474_27_

        if ((cfg.size != null))
        {
            if (_k_.isNum(cfg.size))
            {
                x = y = z = cfg.size
            }
            else
            {
                s = vec(cfg.size)
                x = s.x
                y = s.y
                z = s.z
            }
        }
        else
        {
            x = ((_472_27_=cfg.width) != null ? _472_27_ : 1)
            y = ((_473_27_=cfg.depth) != null ? _473_27_ : 1)
            z = ((_474_27_=cfg.height) != null ? _474_27_ : 1)
        }
        geom = new BufferGeometry()
        xh = x / 2
        yh = y / 2
        zh = z / 2
        vertices = new Float32Array([-xh,-yh,zh,xh,-yh,zh,0,yh,zh,-xh,-yh,-zh,0,yh,-zh,xh,-yh,-zh,xh,-yh,zh,-xh,-yh,zh,-xh,-yh,-zh,-xh,-yh,-zh,xh,-yh,-zh,xh,-yh,zh,-xh,-yh,zh,0,yh,zh,0,yh,-zh,0,yh,-zh,-xh,-yh,-zh,-xh,-yh,zh,0,yh,zh,xh,-yh,zh,xh,-yh,-zh,xh,-yh,-zh,0,yh,-zh,0,yh,zh])
        geom.setAttribute('position',new BufferAttribute(vertices,3))
        if (cfg.dir)
        {
            geom.applyQuaternion(Quaternion.unitVectors(Vector.unitY,cfg.dir))
        }
        if (cfg.pos)
        {
            p = vec(cfg.pos)
            geom.translate(p.x,p.y,p.z)
        }
        geom.computeVertexNormals()
        geom.computeBoundingSphere()
        return geom
    }

    static cornerBox (size = 1, x = 0, y = 0, z = 0)
    {
        var backside, bottomside, cube, frontside, i, leftside, o, rightside, s, topside, vertices

        o = size / 2
        s = 0.9 * o
        i = 0.8 * o
        topside = new BufferGeometry()
        vertices = new Float32Array([i,i,o,-i,i,o,-i,-i,o,i,i,o,-i,-i,o,i,-i,o,s,s,s,-s,s,s,-i,i,o,s,s,s,-i,i,o,i,i,o,-s,s,s,-s,-s,s,-i,-i,o,-s,s,s,-i,-i,o,-i,i,o,-s,-s,s,s,-s,s,i,-i,o,-s,-s,s,i,-i,o,-i,-i,o,s,s,s,i,i,o,i,-i,o,s,s,s,i,-i,o,s,-s,s])
        topside.setAttribute('position',new BufferAttribute(vertices,3))
        rightside = new BufferGeometry()
        rightside.copy(topside)
        rightside.rotateY(deg2rad(90))
        leftside = new BufferGeometry()
        leftside.copy(topside)
        leftside.rotateY(deg2rad(-90))
        backside = new BufferGeometry()
        backside.copy(topside)
        backside.rotateX(deg2rad(-90))
        frontside = new BufferGeometry()
        frontside.copy(topside)
        frontside.rotateX(deg2rad(90))
        bottomside = new BufferGeometry()
        bottomside.copy(topside)
        bottomside.rotateX(deg2rad(-180))
        cube = this.merge(topside,rightside,backside,bottomside,leftside,frontside)
        cube.translate(x,y,z)
        cube.computeVertexNormals()
        cube.computeBoundingSphere()
        return cube
    }
}

module.exports = Geometry