// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}}

var CurveHelper


CurveHelper = (function ()
{
    function CurveHelper ()
    {
        var geom

        this.group = new Group
        geom = Geom.box({size:0.1})
        this.pointMeshes = new THREE.InstancedMesh(geom,Materials.wireframe,100)
        this.group.add(this.pointMeshes)
        geom = Geom.box({size:0.2})
        this.ctrlMeshes = new THREE.InstancedMesh(geom,Materials.wireframe.clone(),10)
        this.ctrlMeshes.material.color.copy(new THREE.Color(0xff0000))
        this.group.add(this.ctrlMeshes)
    }

    CurveHelper.prototype["setCurve"] = function (curve)
    {
        var cp, f, index, mat, num, p

        num = 100
        mat = new THREE.Matrix4
        for (var _27_21_ = index = 0, _27_25_ = num; (_27_21_ <= _27_25_ ? index < num : index > num); (_27_21_ <= _27_25_ ? ++index : --index))
        {
            f = index / num
            p = curve.getPointAt(f)
            mat.setPosition(p)
            this.pointMeshes.setMatrixAt(index,mat)
        }
        var list = _k_.list(curve.curves[0].points)
        for (index = 0; index < list.length; index++)
        {
            cp = list[index]
            mat.setPosition(cp)
            this.ctrlMeshes.setMatrixAt(index,mat)
        }
        this.ctrlMeshes.count = curve.curves[0].points.length
        this.pointMeshes.count = num + 1
        return this.pointMeshes.instanceMatrix.needsUpdate = true
    }

    return CurveHelper
})()

module.exports = CurveHelper