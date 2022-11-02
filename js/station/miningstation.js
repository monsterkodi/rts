// monsterkodi/kode 0.243.0

var _k_ = {extend: function (c,p) {for (var k in p) { if (Object.hasOwn(p, k)) c[k] = p[k] } function ctor() { this.constructor = c; } ctor.prototype = p.prototype; c.prototype = new ctor(); c.__super__ = p.prototype; return c;}}

var CargoStation, MiningStation, Station

CargoStation = require('./cargostation')
Station = require('./station')

MiningStation = (function ()
{
    _k_.extend(MiningStation, CargoStation)
    function MiningStation (cfg)
    {
        var _17_17_

        this.resource = cfg.resource
        cfg.name = ((_17_17_=cfg.name) != null ? _17_17_ : `M${cfg.resource[0]}${Station.id + 1}`)
        MiningStation.__super__.constructor.call(this,cfg)
        this.base.children[0].material = Materials.mining[this.resource]
        this.storage.group.children[0].material = Materials.mining[this.resource]
        this.arm.group.children[4].children[0].material = Materials.mining[this.resource]
        this.storage.startMiningAnimation(this.resource)
        this.arm.resetStorageAnimation()
    }

    MiningStation.prototype["takesCargo"] = function ()
    {
        return false
    }

    MiningStation.prototype["providesCargo"] = function ()
    {
        return this.resource
    }

    MiningStation.prototype["toSave"] = function ()
    {
        var s

        s = MiningStation.__super__.toSave.call(this)
        s.resource = this.resource
        return s
    }

    MiningStation.prototype["carWaitingForCargo"] = function (waitingCar)
    {
        this.waitingCar = waitingCar
    
        if (this.arm.waitingForCar)
        {
            return this.arm.startLoadingToCar(this.waitingCar)
        }
    }

    return MiningStation
})()

module.exports = MiningStation