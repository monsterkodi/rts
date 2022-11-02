// monsterkodi/kode 0.243.0

var _k_ = {extend: function (c,p) {for (var k in p) { if (Object.hasOwn(p, k)) c[k] = p[k] } function ctor() { this.constructor = c; } ctor.prototype = p.prototype; c.prototype = new ctor(); c.__super__ = p.prototype; return c;}}

var Arm, CargoStation, Station, Storage

Station = require('./station')
Storage = require('./storage')
Arm = require('./arm')

CargoStation = (function ()
{
    _k_.extend(CargoStation, Station)
    function CargoStation (cfg)
    {
        CargoStation.__super__.constructor.call(this,cfg)
    
        this.base = world.construct.meshes.station.armbase.clone()
        this.group.add(this.base)
        this.docking = new Group
        this.docking.position.x = -6
        this.group.add(this.docking)
        this.storage = new Storage(this)
        this.storage.group.position.x = 6
        this.group.add(this.storage.group)
        world.physics.addStorage(this.storage)
        this.arm = new Arm(this)
        this.arm.group.position.z = 5.1
        this.group.add(this.arm.group)
        if (cfg.node)
        {
            this.node = world.nodeWithName(cfg.node)
        }
        else
        {
            this.docking.getWorldPosition(Vector.tmp)
            this.node = world.addNode({pos:Vector.tmp,name:'n' + this.name,fixed:true})
            if (cfg.dir)
            {
                this.node.setDir(cfg.dir)
            }
        }
        this.node.station = this
    }

    CargoStation.prototype["hasCargo"] = function ()
    {
        return this.arm.cargo
    }

    return CargoStation
})()

module.exports = CargoStation