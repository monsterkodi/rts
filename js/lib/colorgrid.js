// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}}

var BufferGeometry

BufferGeometry = THREE.BufferGeometry
class Grid extends BufferGeometry
{
    constructor (sx, sy, nx, ny, pd)
    {
        super()
    
        var indices, ox, oy, th, thp, tile, tw, twp, vertices, vs, x, y

        this.type = 'Grid'
        vertices = []
        indices = []
        twp = sx / nx
        thp = sy / ny
        ox = twp / 2 - sx / 2
        oy = thp / 2 - sx / 2
        tw = sx / nx / pd / 2
        th = sy / ny / pd / 2
        vs = 0
        tile = (function (x, y)
        {
            vertices.push(x * twp - tw + ox,y * thp - th + oy,0)
            vertices.push(x * twp + tw + ox,y * thp - th + oy,0)
            vertices.push(x * twp + tw + ox,y * thp + th + oy,0)
            vertices.push(x * twp - tw + ox,y * thp + th + oy,0)
            indices.push(vs + 0,vs + 1,vs + 2)
            indices.push(vs + 2,vs + 3,vs + 0)
            return vs += 4
        }).bind(this)
        for (var _43_17_ = x = 0, _43_21_ = nx; (_43_17_ <= _43_21_ ? x < nx : x > nx); (_43_17_ <= _43_21_ ? ++x : --x))
        {
            for (var _44_21_ = y = 0, _44_25_ = ny; (_44_21_ <= _44_25_ ? y < ny : y > ny); (_44_21_ <= _44_25_ ? ++y : --y))
            {
                tile(x,y)
            }
        }
        this.setIndex(indices)
        this.setAttribute('position',new THREE.Float32BufferAttribute(vertices,3))
        this.computeVertexNormals()
    }
}

class ColorGrid
{
    static mat = new THREE.Matrix4

    constructor (cfg)
    {
        var gridH, gridW, height, mat, padding, width, _64_33_, _65_33_, _66_33_, _67_33_, _68_33_, _72_31_

        gridW = ((_64_33_=cfg.gridWidth) != null ? _64_33_ : cfg.gridSize)
        gridH = ((_65_33_=cfg.gridHeight) != null ? _65_33_ : gridW)
        width = ((_66_33_=cfg.width) != null ? _66_33_ : cfg.size)
        height = ((_67_33_=cfg.height) != null ? _67_33_ : width)
        padding = ((_68_33_=cfg.padding) != null ? _68_33_ : 1.2)
        this.sz = vec(gridW,gridH)
        this.geom = new Grid(width,height,this.sz.x,this.sz.y,padding)
        mat = ((_72_31_=cfg.material) != null ? _72_31_ : [Materials.shinyblack].concat(Object.values(Materials.mining)))
        this.quads = new Mesh(this.geom,mat)
        if (cfg.shadows)
        {
            this.quads.setShadow()
        }
        this.setColumns([])
    }

    setColumns (cols)
    {
        var ai, ci, col, gc, gm, gs, rest, ri, row, vi

        this.geom.clearGroups()
        gs = gc = 0
        vi = ai = 0
        gm = -1
        var list = _k_.list(cols)
        for (ci = 0; ci < list.length; ci++)
        {
            col = list[ci]
            if (ci >= this.sz.x)
            {
                break
            }
            var list1 = _k_.list(col)
            for (ri = 0; ri < list1.length; ri++)
            {
                row = list1[ri]
                if (ri >= this.sz.y)
                {
                    break
                }
                if (row !== gm)
                {
                    if (gm === -1)
                    {
                        gc++
                        gm = row
                    }
                    else
                    {
                        this.geom.addGroup(gs * 6,gc * 6,gm)
                        ai = gs + gc
                        gm = row
                        gc = 1
                        gs = vi
                    }
                }
                else
                {
                    gc++
                }
                vi++
            }
            if (rest = this.sz.y - ri)
            {
                this.geom.addGroup(gs * 6,gc * 6,gm)
                ai = gs + gc
                gm = 0
                gc = rest
                gs = vi
                vi += rest
            }
        }
        if (gc)
        {
            this.geom.addGroup(gs * 6,gc * 6,gm)
            ai = gs + gc
            gs += gc
        }
        if (ai < this.sz.x * this.sz.y)
        {
            return this.geom.addGroup(gs * 6,(this.sz.x * this.sz.y - ai) * 6,0)
        }
    }
}

module.exports = ColorGrid