// monsterkodi/kode 0.243.0

var _k_ = {extend: function (c,p) {for (var k in p) { if (Object.hasOwn(p, k)) c[k] = p[k] } function ctor() { this.constructor = c; } ctor.prototype = p.prototype; c.prototype = new ctor(); c.__super__ = p.prototype; return c;}}

var CargoStation, CentralStation, Station

CargoStation = require('./cargostation')
Station = require('./station')

CentralStation = (function ()
{
    _k_.extend(CentralStation, CargoStation)
    function CentralStation (cfg)
    {
        var label, _16_17_

        cfg.name = ((_16_17_=cfg.name) != null ? _16_17_ : `C${Station.id + 1}`)
        CentralStation.__super__.constructor.call(this,cfg)
        label = world.addLabel({text:'▴➜▪➜●',mono:true,position:[0,-2.61,1.2],color:0xffffff,scale:1.4})
        label.rotateX(deg2rad(90))
        this.group.add(label)
        this.arm.waitingForCar = true
    }

    CentralStation.prototype["hasCargo"] = function ()
    {
        return false
    }

    CentralStation.prototype["takesCargo"] = function ()
    {
        return true
    }

    CentralStation.prototype["providesCargo"] = function ()
    {
        return false
    }

    CentralStation.prototype["carWaitingForUnload"] = function (waitingCar)
    {
        this.waitingCar = waitingCar
    
        if (this.arm.waitingForCar)
        {
            return this.arm.startUnloadingCar(this.waitingCar)
        }
    }

    return CentralStation
})()

module.exports = CentralStation