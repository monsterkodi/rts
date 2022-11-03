// monsterkodi/kode 0.243.0

var _k_

var Cargo


Cargo = (function ()
{
    function Cargo (mesh, resource)
    {
        this.mesh = mesh
        this.resource = resource
    
        this.mesh.setShadow()
    }

    Cargo.prototype["del"] = function ()
    {
        this.mesh.removeFromParent()
        return delete this.mesh
    }

    return Cargo
})()

module.exports = Cargo