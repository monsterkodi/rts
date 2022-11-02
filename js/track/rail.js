// monsterkodi/kode 0.243.0

var _k_

var BufferGeometry

BufferGeometry = THREE.BufferGeometry
class Rail extends BufferGeometry
{
    constructor (curve, segments = 64)
    {
        super()
    
        var frames, generateIndices, generateSegment, i, indices, normal, P, vertex, vertices

        this.type = 'Rail'
        frames = curve.computeFrenetFrames(segments,false)
        this.tangents = frames.tangents
        this.normals = frames.normals
        this.binormals = frames.binormals
        vertex = vec()
        normal = vec()
        P = vec()
        vertices = []
        indices = []
        generateSegment = (function (i)
        {
            var B, N, v

            P = curve.getPointAt(i / segments,P)
            N = frames.normals[i].clone().multiplyScalar(0.35)
            B = frames.binormals[i].clone().multiplyScalar(0.35)
            v = P.clone()
            v.add(N)
            v.add(B)
            vertices.push(v.x,v.y,v.z)
            v = P.clone()
            v.add(N)
            v.sub(B)
            vertices.push(v.x,v.y,v.z)
            v = P.clone()
            v.sub(N)
            v.sub(B)
            vertices.push(v.x,v.y,v.z)
            v = P.clone()
            v.sub(N)
            v.add(B)
            vertices.push(v.x,v.y,v.z)
            v = P.clone()
            v.add(N)
            v.add(B)
            return vertices.push(v.x,v.y,v.z)
        }).bind(this)
        generateIndices = function ()
        {
            var a, b, c, d, i, j

            for (var _59_21_ = j = 1, _59_24_ = segments; (_59_21_ <= _59_24_ ? j <= segments : j >= segments); (_59_21_ <= _59_24_ ? ++j : --j))
            {
                for (i = 1; i <= 4; i++)
                {
                    a = 5 * (j - 1) + (i - 1)
                    b = 5 * j + (i - 1)
                    c = 5 * j + i
                    d = 5 * (j - 1) + i
                    indices.push(a,b,d)
                    indices.push(b,c,d)
                }
            }
        }
        for (var _70_17_ = i = 0, _70_20_ = segments; (_70_17_ <= _70_20_ ? i <= segments : i >= segments); (_70_17_ <= _70_20_ ? ++i : --i))
        {
            generateSegment(i)
        }
        generateIndices()
        this.setIndex(indices)
        this.setAttribute('position',new THREE.Float32BufferAttribute(vertices,3))
        this.computeVertexNormals()
        curve.updateArcLengths()
    }
}

module.exports = Rail