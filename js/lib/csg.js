// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}, empty: function (l) {return l==='' || l===null || l===undefined || l!==l || typeof(l) === 'object' && Object.keys(l).length === 0}}

var nbuf2, nbuf3, tmpm3, ttvv0, tv0, tv1

class CSG
{
    constructor ()
    {
        this.polygons = []
    }

    clone ()
    {
        var csg

        csg = new CSG
        csg.polygons = this.polygons.map(function (p)
        {
            return p.clone()
        })
        return csg
    }

    union (csg)
    {
        var a, b

        a = new Node(this.clone().polygons)
        b = new Node(csg.clone().polygons)
        a.clipTo(b)
        b.clipTo(a)
        b.invert()
        b.clipTo(a)
        b.invert()
        a.build(b.allPolygons())
        return CSG.fromPolygons(a.allPolygons())
    }

    subtract (csg)
    {
        var a, b

        a = new Node(this.clone().polygons)
        b = new Node(csg.clone().polygons)
        a.invert()
        a.clipTo(b)
        b.clipTo(a)
        b.invert()
        b.clipTo(a)
        b.invert()
        a.build(b.allPolygons())
        a.invert()
        return CSG.fromPolygons(a.allPolygons())
    }

    intersect (csg)
    {
        var a, b

        a = new Node(this.clone().polygons)
        b = new Node(csg.clone().polygons)
        a.invert()
        b.clipTo(a)
        b.invert()
        a.clipTo(b)
        b.clipTo(a)
        a.build(b.allPolygons())
        a.invert()
        return CSG.fromPolygons(a.allPolygons())
    }
}


CSG.fromPolygons = function (polygons)
{
    var csg

    csg = new CSG()
    csg.polygons = polygons
    return csg
}
tv0 = new Vector()
tv1 = new Vector()
class Vertex
{
    constructor (pos, normal, uv, color)
    {
        this.pos = new Vector().copy(pos)
        this.normal = new Vector().copy(normal)
        if (uv)
        {
            this.uv = new Vector().copy(uv)
            this.uv.z = 0
        }
        if (color)
        {
            this.color = new Vector().copy(color)
        }
    }

    clone ()
    {
        return new Vertex(this.pos,this.normal,this.uv,this.color)
    }

    flip ()
    {
        return this.normal.negate()
    }

    interpolate (other, t)
    {
        var color, normal, pos, uv

        pos = this.pos.clone().lerp(other.pos,t)
        normal = this.normal.clone().lerp(other.normal,t)
        uv = this.uv && other.uv && this.uv.clone().lerp(other.uv,t)
        color = this.color && other.color && this.color.clone().lerp(other.color,t)
        return new Vertex(pos,normal,uv,color)
    }
}

class Plane
{
    static EPSILON = 1e-5

    constructor (normal, w)
    {
        this.normal = normal
        this.w = w
    }

    clone ()
    {
        return new Plane(this.normal.clone(),this.w)
    }

    flip ()
    {
        this.normal.negate()
        return this.w = -this.w
    }

    splitPolygon (polygon, coplanarFront, coplanarBack, front, back)
    {
        var b, BACK, COPLANAR, f, FRONT, i, j, polygonType, SPANNING, t, ti, tj, type, types, v, vi, vj

        COPLANAR = 0
        FRONT = 1
        BACK = 2
        SPANNING = 3
        polygonType = 0
        types = []
        for (var _147_17_ = i = 0, _147_21_ = polygon.vertices.length; (_147_17_ <= _147_21_ ? i < polygon.vertices.length : i > polygon.vertices.length); (_147_17_ <= _147_21_ ? ++i : --i))
        {
            t = this.normal.dot(polygon.vertices[i].pos) - this.w
            type = ((t < -Plane.EPSILON) ? BACK : ((t > Plane.EPSILON) ? FRONT : COPLANAR))
            polygonType |= type
            types.push(type)
        }
        switch (polygonType)
        {
            case FRONT:
                front.push(polygon)
                break
            case BACK:
                back.push(polygon)
                break
            case COPLANAR:
                ((this.normal.dot(polygon.plane.normal) > 0 ? coplanarFront : coplanarBack)).push(polygon)
                break
            case SPANNING:
                f = []
                b = []
                for (var _164_25_ = i = 0, _164_29_ = polygon.vertices.length; (_164_25_ <= _164_29_ ? i < polygon.vertices.length : i > polygon.vertices.length); (_164_25_ <= _164_29_ ? ++i : --i))
                {
                    j = (i + 1) % polygon.vertices.length
                    ti = types[i]
                    tj = types[j]
                    vi = polygon.vertices[i]
                    vj = polygon.vertices[j]
                    if (ti !== BACK)
                    {
                        f.push(vi)
                    }
                    if (ti !== FRONT)
                    {
                        b.push((ti !== BACK ? vi.clone() : vi))
                    }
                    if ((ti | tj) === SPANNING)
                    {
                        t = (this.w - this.normal.dot(vi.pos)) / this.normal.dot(tv0.copy(vj.pos).sub(vi.pos))
                        v = vi.interpolate(vj,t)
                        f.push(v)
                        b.push(v.clone())
                    }
                }
                if (f.length >= 3)
                {
                    front.push(new Polygon(f,polygon.shared))
                }
                if (b.length >= 3)
                {
                    back.push(new Polygon(b,polygon.shared))
                }
                break
        }

        return this
    }
}


Plane.fromPoints = function (a, b, c)
{
    var n

    n = tv0.copy(b).sub(a).cross(tv1.copy(c).sub(a)).normalize()
    return new Plane(n.clone(),n.dot(a))
}
class Polygon
{
    constructor (vertices, shared)
    {
        this.vertices = vertices
        this.shared = shared
        this.plane = Plane.fromPoints(vertices[0].pos,vertices[1].pos,vertices[2].pos)
    }

    clone ()
    {
        return new Polygon(this.vertices.map(function (v)
        {
            return v.clone()
        }),this.shared)
    }

    flip ()
    {
        this.vertices.reverse().forEach(function (v)
        {
            return v.flip()
        })
        this.plane.flip()
        return this
    }
}

class Node
{
    constructor (polygons)
    {
        this.plane = null
        this.front = null
        this.back = null
        this.polygons = []
        if (polygons)
        {
            this.build(polygons)
        }
    }

    clone ()
    {
        var node

        node = new Node()
        node.plane = this.plane && this.plane.clone()
        node.front = this.front && this.front.clone()
        node.back = this.back && this.back.clone()
        node.polygons = this.polygons.map(function (p)
        {
            return p.clone()
        })
        return node
    }

    invert ()
    {
        var p, temp, _253_14_, _254_14_, _255_13_

        var list = _k_.list(this.polygons)
        for (var _250_14_ = 0; _250_14_ < list.length; _250_14_++)
        {
            p = list[_250_14_]
            p.flip()
        }
        ;(this.plane != null ? this.plane.flip() : undefined)
        ;(this.front != null ? this.front.invert() : undefined)
        ;(this.back != null ? this.back.invert() : undefined)
        temp = this.front
        this.front = this.back
        this.back = temp
        return this
    }

    clipPolygons (polygons)
    {
        var back, front, p

        if (!this.plane)
        {
            return polygons.slice()
        }
        front = []
        back = []
        var list = _k_.list(polygons)
        for (var _266_14_ = 0; _266_14_ < list.length; _266_14_++)
        {
            p = list[_266_14_]
            this.plane.splitPolygon(p,front,back,front,back)
        }
        if (this.front)
        {
            front = this.front.clipPolygons(front)
        }
        if (this.back)
        {
            back = this.back.clipPolygons(back)
        }
        else
        {
            back = []
        }
        return front.concat(back)
    }

    clipTo (bsp)
    {
        var _279_14_, _280_13_

        this.polygons = bsp.clipPolygons(this.polygons)
        ;(this.front != null ? this.front.clipTo(bsp) : undefined)
        ;(this.back != null ? this.back.clipTo(bsp) : undefined)
        return this
    }

    allPolygons ()
    {
        var polygons

        polygons = this.polygons.slice()
        if (this.front)
        {
            polygons = polygons.concat(this.front.allPolygons())
        }
        if (this.back)
        {
            polygons = polygons.concat(this.back.allPolygons())
        }
        return polygons
    }

    build (polygons)
    {
        var back, front, p, _301_15_, _310_19_, _314_18_

        if (_k_.empty(polygons))
        {
            return
        }
        this.plane = ((_301_15_=this.plane) != null ? _301_15_ : polygons[0].plane.clone())
        front = []
        back = []
        var list = _k_.list(polygons)
        for (var _306_14_ = 0; _306_14_ < list.length; _306_14_++)
        {
            p = list[_306_14_]
            this.plane.splitPolygon(p,this.polygons,this.polygons,front,back)
        }
        if (front.length)
        {
            this.front = ((_310_19_=this.front) != null ? _310_19_ : new Node())
            this.front.build(front)
        }
        if (back.length)
        {
            this.back = ((_314_18_=this.back) != null ? _314_18_ : new Node())
            this.back.build(back)
        }
        return this
    }
}


CSG.fromGeometry = function (geom, objectIndex)
{
    var colorattr, i, index, j, l, normalattr, nx, ny, nz, pli, polys, posattr, triCount, uvattr, vertices, vi, vp, vt, x, y, z

    polys = []
    if (geom.isBufferGeometry)
    {
        posattr = geom.attributes.position
        normalattr = geom.attributes.normal
        uvattr = geom.attributes.uv
        colorattr = geom.attributes.color
        if (geom.index)
        {
            index = geom.index.array
        }
        else
        {
            index = new Array((posattr.array.length / posattr.itemSize) | 0)
            for (var _339_21_ = i = 0, _339_25_ = index.length; (_339_21_ <= _339_25_ ? i < index.length : i > index.length); (_339_21_ <= _339_25_ ? ++i : --i))
            {
                index[i] = i
            }
        }
        triCount = (index.length / 3) | 0
        polys = new Array(triCount)
        i = 0
        l = index.length
        pli = 0
        while (i < l)
        {
            vertices = new Array(3)
            for (j = 0; j < 3; j++)
            {
                vi = index[i + j]
                vp = vi * 3
                vt = vi * 2
                x = posattr.array[vp]
                y = posattr.array[vp + 1]
                z = posattr.array[vp + 2]
                nx = normalattr.array[vp]
                ny = normalattr.array[vp + 1]
                nz = normalattr.array[vp + 2]
                vertices[j] = new Vertex({x:x,y:y,z:z},{x:nx,y:ny,z:nz},(uvattr ? {x:uvattr.array[vt],y:uvattr.array[vt + 1],z:0} : null),(colorattr ? {x:colorattr.array[vt],y:colorattr.array[vt + 1],z:colorattr.array[vt + 2]} : null))
            }
            polys[pli] = new Polygon(vertices,objectIndex)
            i += 3
            pli++
        }
    }
    else
    {
        console.error("Unsupported CSG input type:" + geom.type)
    }
    return CSG.fromPolygons(polys)
}
ttvv0 = new THREE.Vector3()
tmpm3 = new THREE.Matrix3()

CSG.fromMesh = function (mesh, objectIndex)
{
    var csg, p, v

    csg = CSG.fromGeometry(mesh.geometry,objectIndex)
    tmpm3.getNormalMatrix(mesh.matrix)
    var list = _k_.list(csg.polygons)
    for (var _384_10_ = 0; _384_10_ < list.length; _384_10_++)
    {
        p = list[_384_10_]
        var list1 = _k_.list(p.vertices)
        for (var _385_14_ = 0; _385_14_ < list1.length; _385_14_++)
        {
            v = list1[_385_14_]
            v.pos.copy(ttvv0.copy(v.pos).applyMatrix4(mesh.matrix))
            v.normal.copy(ttvv0.copy(v.normal).applyMatrix3(tmpm3))
        }
    }
    return csg
}

nbuf3 = function (ct)
{
    return {top:0,array:new Float32Array(ct),write:function (v)
    {
        this.array[this.top++] = v.x
        this.array[this.top++] = v.y
        this.array[this.top++] = v.z
        return
    }}
}

nbuf2 = function (ct)
{
    return {top:0,array:new Float32Array(ct),write:function (v)
    {
        this.array[this.top++] = v.x
        this.array[this.top++] = v.y
        return
    }}
}

CSG.toGeometry = function (csg)
{
    var colors, gbase, geom, gi, grps, index, normals, ps, triCount, uvs, vertices

    ps = csg.polygons
    triCount = 0
    ps.forEach(function (p)
    {
        return triCount += p.vertices.length - 2
    })
    geom = new THREE.BufferGeometry()
    vertices = nbuf3(triCount * 3 * 3)
    normals = nbuf3(triCount * 3 * 3)
    colors = undefined
    uvs = undefined
    grps = []
    ps.forEach(function (p)
    {
        var j, pvlen, pvs, _430_27_

        pvs = p.vertices
        pvlen = pvs.length
        if (p.shared)
        {
            grps[p.shared] = ((_430_27_=grps[p.shared]) != null ? _430_27_ : [])
        }
        if (pvlen)
        {
            if (pvs[0].color)
            {
                colors = (colors != null ? colors : nbuf3(triCount * 3 * 3))
            }
            if (pvs[0].uv)
            {
                uvs = (uvs != null ? uvs : nbuf2(triCount * 2 * 3))
            }
        }
        for (var _436_17_ = j = 3, _436_20_ = pvlen; (_436_17_ <= _436_20_ ? j <= pvlen : j >= pvlen); (_436_17_ <= _436_20_ ? ++j : --j))
        {
            if (p.shared)
            {
                grps[p.shared].push(vertices.top / 3,(vertices.top / 3) + 1,(vertices.top / 3) + 2)
            }
            vertices.write(pvs[0].pos)
            vertices.write(pvs[j - 2].pos)
            vertices.write(pvs[j - 1].pos)
            normals.write(pvs[0].normal)
            normals.write(pvs[j - 2].normal)
            normals.write(pvs[j - 1].normal)
            if (uvs && pvs[0].uv)
            {
                uvs.write(pvs[0].uv)
                uvs.write(pvs[j - 2].uv)
                uvs.write(pvs[j - 1].uv)
            }
            if (colors)
            {
                colors.write(pvs[0].color)
                colors.write(pvs[j - 2].color)
                colors.write(pvs[j - 1].color)
            }
        }
    })
    geom.setAttribute('position',new THREE.BufferAttribute(vertices.array,3))
    geom.setAttribute('normal',new THREE.BufferAttribute(normals.array,3))
    if (uvs)
    {
        geom.setAttribute('uv',new THREE.BufferAttribute(uvs.array,2))
    }
    if (colors)
    {
        geom.setAttribute('color',new THREE.BufferAttribute(colors.array,3))
    }
    if (grps.length)
    {
        index = []
        gbase = 0
        for (var _463_18_ = gi = 0, _463_22_ = grps.length; (_463_18_ <= _463_22_ ? gi < grps.length : gi > grps.length); (_463_18_ <= _463_22_ ? ++gi : --gi))
        {
            geom.addGroup(gbase,grps[gi].length,gi)
            gbase += grps[gi].length
            index = index.concat(grps[gi])
        }
        geom.setIndex(index)
    }
    return geom
}

CSG.toMesh = function (csg, toMatrix, toMaterial)
{
    var geom, inv, m

    geom = CSG.toGeometry(csg)
    inv = new THREE.Matrix4().copy(toMatrix).invert()
    geom.applyMatrix4(inv)
    geom.computeBoundingSphere()
    geom.computeBoundingBox()
    m = new THREE.Mesh(geom,toMaterial)
    m.matrix.copy(toMatrix)
    m.matrix.decompose(m.position,m.quaternion,m.scale)
    m.rotation.setFromQuaternion(m.quaternion)
    m.updateMatrixWorld()
    m.castShadow = m.receiveShadow = true
    return m
}
module.exports = CSG