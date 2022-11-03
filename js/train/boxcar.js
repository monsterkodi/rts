// monsterkodi/kode 0.243.0

var _k_ = {extend: function (c,p) {for (var k in p) { if (Object.hasOwn(p, k)) c[k] = p[k] } function ctor() { this.constructor = c; } ctor.prototype = p.prototype; c.prototype = new ctor(); c.__super__ = p.prototype; return c;}}

var Boxcar, Car

Car = require('./car')

Boxcar = (function ()
{
    _k_.extend(Boxcar, Car)
    function Boxcar (train)
    {
        Boxcar.__super__.constructor.call(this,train,world.construct.meshes.boxcar.clone())
    }

    Boxcar.prototype["toSave"] = function ()
    {
        var s

        s = {type:'boxcar'}
        if (this.cargo)
        {
            s.cargo = this.cargo.resource
        }
        return s
    }

    Boxcar.prototype["isEmpty"] = function ()
    {
        return !this.hasCargo()
    }

    Boxcar.prototype["hasCargo"] = function ()
    {
        return this.cargo
    }

    Boxcar.prototype["takeCargo"] = function ()
    {
        var c

        delete this.waitingForUnload
        c = this.cargo
        delete (c != null ? c.mesh.handler : undefined)
        delete this.cargo
        return c
    }

    Boxcar.prototype["setCargo"] = function (cargo)
    {
        this.cargo = cargo
    
        delete this.waitingForCargo
        this.cargo.mesh.handler = this
        this.mesh.add(this.cargo.mesh)
        this.cargo.mesh.quaternion.identity()
        return this.cargo.mesh.position.set(0,0.85,0)
    }

    Boxcar.prototype["setColor"] = function (color)
    {
        Boxcar.__super__.setColor.call(this,color)
    
        this.mesh.children[0].material = this.mesh.children[0].material.clone()
        return this.mesh.children[0].material.emissive.copy(color)
    }

    Boxcar.prototype["setColorByName"] = function (name)
    {
        this.setColor(Colors.train[name])
        this.mesh.children[0].material = this.mesh.children[0].material.clone()
        return this.mesh.children[0].material.emissive.copy(Colors.piston[name])
    }

    Boxcar.prototype["deadEye"] = function ()
    {
        return this.mesh.children[0].material = Materials.train.window
    }

    return Boxcar
})()

module.exports = Boxcar