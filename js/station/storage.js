// monsterkodi/kode 0.243.0

var _k_ = {max: function () { m = -Infinity; for (a of arguments) { if (Array.isArray(a)) {m = _k_.max.apply(_k_.max,[m].concat(a))} else {n = parseFloat(a); if(!isNaN(n)){m = n > m ? n : m}}}; return m }, min: function () { m = Infinity; for (a of arguments) { if (Array.isArray(a)) {m = _k_.min.apply(_k_.min,[m].concat(a))} else {n = parseFloat(a); if(!isNaN(n)){m = n < m ? n : m}}}; return m }}

var Cargo, Storage

Cargo = require('./cargo')

Storage = (function ()
{
    function Storage (station)
    {
        var base, baseMesh

        this.station = station
    
        this["animateMining"] = this["animateMining"].bind(this)
        this["animateStoring"] = this["animateStoring"].bind(this)
        this.name = this.station.name + '.Storage'
        this.numCargoStored = 0
        this.group = new Group
        this.group.name = this.name
        this.frame = world.construct.meshes.station.storage.clone()
        base = Geom.merge(Geom.quad({size:[4.4,4.4],normal:Vector.unitZ}),Geom.quad({size:[4.4,4.4],normal:Vector.minusZ,pos:[0,0,-0.1]}))
        baseMesh = new Mesh(base,Materials.station.side)
        baseMesh.setShadow()
        this.group.add(baseMesh)
        this.group.add(this.frame)
        world.addObject(this.group)
        world.addPickable(this.group)
    }

    Storage.prototype["hasCargo"] = function ()
    {
        return this.cargo
    }

    Storage.prototype["storeCargo"] = function (cargo)
    {
        this.startStoringAnimation(cargo.resource)
        cargo.del()
        return this.numCargoStored++
    }

    Storage.prototype["startStoringAnimation"] = function (resource)
    {
        this.resource = resource
    
        this.animTime = 0
        this.animDuration = 10
        this.box = new Mesh(Geom.box({size:2,pos:[0,0,1]}),Materials.mining[this.resource])
        this.box.scale.set(1,1,1)
        this.box.position.z = 1.75
        this.box.setShadow()
        this.group.add(this.box)
        return world.addAnimation(this.animateStoring)
    }

    Storage.prototype["animateStoring"] = function (delta, timeSum)
    {
        var animFactor

        this.animTime += delta
        if ((animFactor = this.animTime / this.animDuration) <= 1)
        {
            this.box.scale.set(1,1,1 - (1 / 0.75) * _k_.max(0,animFactor - 0.25))
            this.box.position.z = 1.75 - 1.75 * _k_.min(1,animFactor * 8)
            return world.addAnimation(this.animateStoring)
        }
        else
        {
            this.box.removeFromParent()
            delete this.box
            return this.station.cargoStored(this.resource)
        }
    }

    Storage.prototype["cargoTaken"] = function ()
    {
        delete this.cargo
        return this.startMiningAnimation()
    }

    Storage.prototype["startMiningAnimation"] = function ()
    {
        this.animTime = 0
        this.animDuration = 18
        this.box = new Mesh(Geom.box({size:2}),Materials.mining[this.station.resource])
        this.box.position.z = 0
        this.box.scale.set(1,1,0.01)
        this.box.setShadow()
        this.group.add(this.box)
        return world.addAnimation(this.animateMining)
    }

    Storage.prototype["animateMining"] = function (delta, timeSum)
    {
        var animFactor, scaleFactor

        this.animTime += delta
        if ((animFactor = this.animTime / this.animDuration) <= 1)
        {
            scaleFactor = _k_.min(1,animFactor * 2)
            this.box.position.z = _k_.max(scaleFactor,3.5 * (animFactor - 0.5) + scaleFactor)
            this.box.scale.set(1,1,scaleFactor)
            return world.addAnimation(this.animateMining)
        }
        else
        {
            return this.miningEnded()
        }
    }

    Storage.prototype["miningEnded"] = function ()
    {
        this.box.scale.set(1,1,1)
        this.cargo = new Cargo(this.box,this.station.resource)
        return delete this.box
    }

    return Storage
})()

module.exports = Storage