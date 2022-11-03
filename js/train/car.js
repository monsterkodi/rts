// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}}

var Car


Car = (function ()
{
    function Car (train, mesh)
    {
        var child

        this.train = train
        this.mesh = mesh
    
        this["onDrag"] = this["onDrag"].bind(this)
        world.addObject(this.mesh)
        world.addPickable(this.mesh)
        this.mesh.handler = this
        var list = _k_.list(this.mesh.children)
        for (var _17_18_ = 0; _17_18_ < list.length; _17_18_++)
        {
            child = list[_17_18_]
            child.handler = this
        }
    }

    Car.prototype["del"] = function ()
    {
        world.removeBody(this.body)
        world.removeObject(this.mesh)
        return world.removePickable(this.mesh)
    }

    Car.prototype["onDrag"] = function (hit, downHit)
    {
        var dist

        if (this.body)
        {
            return
        }
        dist = hit.point.distanceTo(downHit.point)
        if (dist > 0.5)
        {
            return this.train.explode()
        }
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