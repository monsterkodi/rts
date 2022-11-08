// monsterkodi/kode 0.243.0

var _k_ = {extend: function (c,p) {for (var k in p) { if (Object.hasOwn(p, k)) c[k] = p[k] } function ctor() { this.constructor = c; } ctor.prototype = p.prototype; c.prototype = new ctor(); c.__super__ = p.prototype; return c;}}

var CargoStation, CentralStation, ColorGrid, GRID_SIZE, Station

CargoStation = require('./cargostation')
ColorGrid = require('../lib/colorgrid')
Station = require('./station')
GRID_SIZE = 10

CentralStation = (function ()
{
    _k_.extend(CentralStation, CargoStation)
    CentralStation["storage"] = {water:0,stuff:0,blood:0,chalk:0}
    function CentralStation (cfg)
    {
        var label, _25_17_

        this["updateGrid"] = this["updateGrid"].bind(this)
        cfg.name = ((_25_17_=cfg.name) != null ? _25_17_ : `C${Station.id + 1}`)
        CentralStation.__super__.constructor.call(this,cfg)
        label = world.addLabel({text:'▴➜▪➜●',mono:true,position:[0,-2.61,1.2],color:0xffffff,scale:1.4})
        label.rotateX(deg2rad(90))
        this.group.add(label)
        this.arm.waitingForCar = true
        this.grid = new ColorGrid({gridSize:GRID_SIZE,size:4})
        this.grid.quads.rotateX(deg2rad(90))
        this.grid.quads.position.z = 2.5
        this.grid.quads.position.y = -2.61
        this.group.add(this.grid.quads)
        this.gridShiftTime = 0
        this.gridColumns = [[]]
        world.addAnimation(this.updateGrid)
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

    CentralStation.prototype["resourceIndex"] = function (resource)
    {
        return 1 + Object.keys(Colors.mining).indexOf(resource)
    }

    CentralStation.prototype["cargoStored"] = function (resource)
    {
        CentralStation.storage[resource]++
        post.emit('centralStorage',CentralStation.storage,resource)
        if (this.gridColumns[0].length === GRID_SIZE)
        {
            this.gridShiftTime = 0
            this.gridColumns.unshift([])
        }
        this.gridColumns[0].push(this.resourceIndex(resource))
        return this.grid.setColumns(this.gridColumns)
    }

    CentralStation.prototype["updateGrid"] = function (scaledDelta, timeSum)
    {
        this.gridShiftTime += scaledDelta
        if (this.gridShiftTime > 51 * GRID_SIZE)
        {
            this.gridShiftTime = 0
            this.gridColumns.unshift([])
            while (this.gridColumns.length > GRID_SIZE)
            {
                this.gridColumns.pop()
            }
            this.grid.setColumns(this.gridColumns)
        }
        return world.addAnimation(this.updateGrid)
    }

    return CentralStation
})()

module.exports = CentralStation