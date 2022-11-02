// monsterkodi/kode 0.243.0

var _k_

var CargoSelector


CargoSelector = (function ()
{
    function CargoSelector (engine)
    {
        var mat, mesh

        this.engine = engine
    
        this["onMouseUp"] = this["onMouseUp"].bind(this)
        this["onMouseDown"] = this["onMouseDown"].bind(this)
        this["onLeave"] = this["onLeave"].bind(this)
        this.train = this.engine.train
        this.group = new Group
        this.group.position.y = 0.85
        mesh = new Mesh(Geom.cylbox({radius:0.5,height:0.35,length:3,sgmt:16}),Materials.train.window)
        mesh.handler = this
        mesh.name = 'cargo'
        mesh.visible = false
        this.group.add(mesh)
        mat = Materials[(this.train.resource.stuff ? 'mining' : 'selector')].stuff
        this.stuff = new Mesh(Geom.cylinder({dir:Vector.unitY,radius:0.4,height:0.4,sgmt:32,pos:[0,0.2,0]}),mat)
        this.stuff.position.z = 1
        this.stuff.handler = this
        this.stuff.name = 'stuff'
        this.stuff.setShadow()
        this.group.add(this.stuff)
        mat = Materials[(this.train.resource.water ? 'mining' : 'selector')].water
        this.water = new Mesh(Geom.cylinder({dir:Vector.unitY,radius:0.4,height:0.4,sgmt:32,pos:[0,0.2,0]}),mat)
        this.water.handler = this
        this.water.name = 'water'
        this.water.setShadow()
        this.group.add(this.water)
        mat = Materials[(this.train.resource.blood ? 'mining' : 'selector')].blood
        this.blood = new Mesh(Geom.cylinder({dir:Vector.unitY,radius:0.4,height:0.4,sgmt:24,pos:[0,0.2,0]}),mat)
        this.blood.position.z = -1
        this.blood.handler = this
        this.blood.name = 'blood'
        this.blood.setShadow()
        this.group.add(this.blood)
        post.on('mouseDown',this.onMouseDown)
        this.engine.mesh.add(this.group)
    }

    CargoSelector.prototype["del"] = function ()
    {
        if (this.group)
        {
            delete this.engine.cargoSelector
            post.removeListener('mouseDown',this.onMouseDown)
            this.group.removeFromParent()
            return delete this.group
        }
    }

    CargoSelector.prototype["onEnter"] = function (hit, prevHit, event)
    {
        var r

        switch (hit.name)
        {
            case 'stuff':
            case 'blood':
            case 'water':
                this[hit.name].scale.set(1,1.5,1)
                break
        }

        var list = ['stuff','blood','water']
        for (var _62_14_ = 0; _62_14_ < list.length; _62_14_++)
        {
            r = list[_62_14_]
            if (!this.train.resource[r])
            {
                this.group.add(this[r])
            }
        }
    }

    CargoSelector.prototype["onLeave"] = function (hit, nextHit, event)
    {
        var r

        switch (hit.name)
        {
            case 'stuff':
            case 'blood':
            case 'water':
                this[hit.name].scale.set(1,1,1)
                break
        }

        var list = ['stuff','blood','water']
        for (var _71_14_ = 0; _71_14_ < list.length; _71_14_++)
        {
            r = list[_71_14_]
            if (!this.train.resource[r])
            {
                this[r].removeFromParent()
            }
        }
    }

    CargoSelector.prototype["onMouseDown"] = function (hit, event)
    {
        if (!hit)
        {
            return
        }
        switch (hit.name)
        {
            case 'stuff':
            case 'blood':
            case 'water':
                return this[hit.name].scale.set(1,1,1)

            case 'cargo':
                break
            default:
                if (event.buttons === 1)
            {
                if (this.train.resource['water'] && this.train.resource['blood'] && this.train.resource['stuff'])
                {
                    return this.del()
                }
            }
        }

    }

    CargoSelector.prototype["onMouseUp"] = function (hit, downHit)
    {
        switch (hit.name)
        {
            case 'stuff':
            case 'blood':
            case 'water':
                this[hit.name].scale.set(1,1.5,1)
                this.train.resource[hit.name] = !this.train.resource[hit.name]
                if (this.train.resource[hit.name])
                {
                    return this[hit.name].material = Materials.mining[hit.name]
                }
                else
                {
                    return this[hit.name].material = Materials.selector[hit.name]
                }
                break
        }

    }

    return CargoSelector
})()

module.exports = CargoSelector