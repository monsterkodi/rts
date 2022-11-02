// monsterkodi/kode 0.243.0

var _k_

class GridHelper extends LineSegments
{
    constructor (size = 600)
    {
        var c, c1, c2, c3, c4, color, colors, geom, halfSize, i, j, material, vertices

        c1 = new Color(0x000000)
        c2 = new Color(0x303030)
        c3 = new Color(0x383838)
        c4 = new Color(0x404040)
        halfSize = size / 2
        vertices = []
        colors = []
        j = 0
        for (var _24_17_ = i = -halfSize, _24_29_ = halfSize; (_24_17_ <= _24_29_ ? i < halfSize : i > halfSize); (_24_17_ <= _24_29_ ? ++i : --i))
        {
            vertices.push(-halfSize,i,0,halfSize,i,0)
            vertices.push(i,-halfSize,0,i,halfSize,0)
            color = (i === 0 ? c1 : ((i % 12 === 0) ? c2 : ((i % 6 === 0) ? c3 : c4)))
            for (c = 0; c < 4; c++)
            {
                color.toArray(colors,j)
                j += 3
            }
        }
        geom = new BufferGeometry()
        geom.setAttribute('position',new THREE.Float32BufferAttribute(vertices,3))
        geom.setAttribute('color',new THREE.Float32BufferAttribute(colors,3))
        material = new THREE.LineBasicMaterial({vertexColors:true,polygonOffset:true,polygonOffsetFactor:-1.0})
        super(geom,material)
    }

    dispose ()
    {
        this.geometry.dispose()
        return this.material.dispose()
    }
}

module.exports = GridHelper