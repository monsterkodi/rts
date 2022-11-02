// monsterkodi/kode 0.243.0

var _k_

var Station


Station = (function ()
{
    Station["id"] = 0
    function Station (cfg)
    {
        var label, _17_26_

        this["toSave"] = this["toSave"].bind(this)
        Station.id++
        this.name = ((_17_26_=cfg.name) != null ? _17_26_ : ("S" + Station.id))
        this.group = new Group
        if (cfg.pos)
        {
            this.group.position.copy(vec(cfg.pos))
        }
        if (cfg.dir)
        {
            this.group.quaternion.copy(Quaternion.unitVectors(Vector.unitY,cfg.dir))
        }
        this.group.station = this
        this.group.name = this.name
        this.group.toSave = this.toSave
        this.group.toSave.key = 'stations'
        label = world.addLabel({text:this.name,mono:true,position:[0,-2.61,3.2],color:0xffffff,scale:1.4})
        label.rotateX(deg2rad(90))
        this.group.add(label)
        world.addObject(this.group)
        world.addPickable(this.group)
        world.physics.addStation(this)
    }

    Station.prototype["toSave"] = function ()
    {
        return {name:this.name,pos:this.group.position,dir:vec(Vector.unitY).applyQuaternion(this.group.quaternion),node:this.node.name}
    }

    Station.prototype["del"] = function ()
    {
        world.removeObject(this.group)
        return world.removePickable(this.group)
    }

    Station.prototype["update"] = function (delta, timeSum)
    {
        var advance

        return advance = delta * this.speed
    }

    return Station
})()

module.exports = Station