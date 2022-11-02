// monsterkodi/kode 0.243.0

var _k_

var Car


Car = (function ()
{
    function Car (train, mesh)
    {
        this.train = train
        this.mesh = mesh
    
        world.addObject(this.mesh)
        world.addPickable(this.mesh)
    }

    Car.prototype["del"] = function ()
    {
        world.removeBody(this.body)
        world.removeObject(this.mesh)
        return world.removePickable(this.mesh)
    }

    Car.prototype["delta"] = function ()
    {
        return this.train.carDelta(this)
    }

    Car.prototype["nextNode"] = function ()
    {
        return this.train.path.nextNode(this.delta())
    }

    Car.prototype["nextDelta"] = function ()
    {
        return this.delta() + this.nextDistance()
    }

    Car.prototype["nextDistance"] = function ()
    {
        return this.train.path.nextDistance(this.delta())
    }

    Car.prototype["update"] = function (delta, timeSum)
    {}

    Car.prototype["setColor"] = function (color)
    {
        this.mesh.material = this.mesh.material.clone()
        return this.mesh.material.color.copy(color)
    }

    Car.prototype["moveToPathDelta"] = function (path, delta)
    {
        return path.moveMesh(this.mesh,delta)
    }

    return Car
})()

module.exports = Car