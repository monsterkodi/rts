// monsterkodi/kode 0.243.0

var _k_ = {extend: function (c,p) {for (var k in p) { if (Object.hasOwn(p, k)) c[k] = p[k] } function ctor() { this.constructor = c; } ctor.prototype = p.prototype; c.prototype = new ctor(); c.__super__ = p.prototype; return c;}, list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}}

var Car, CargoSelector, Engine

Car = require('./car')
CargoSelector = require('./cargoselector')

Engine = (function ()
{
    _k_.extend(Engine, Car)
    function Engine (train)
    {
        var child, label

        this["onLeave"] = this["onLeave"].bind(this)
        this["onDragDone"] = this["onDragDone"].bind(this)
        this["onDrag"] = this["onDrag"].bind(this)
        this["onEnter"] = this["onEnter"].bind(this)
        Engine.__super__.constructor.call(this,train,world.construct.meshes.engine.clone())
        label = world.addLabel({text:this.train.name,size:0.5,mono:true})
        label.position.z = 2.0
        label.color = 0xffffff
        label.name = this.train.name + '.label'
        this.mesh.add(label)
        this.mesh.handler = this
        var list = _k_.list(this.mesh.children)
        for (var _25_18_ = 0; _25_18_ < list.length; _25_18_++)
        {
            child = list[_25_18_]
            child.handler = this
        }
    }

    Engine.prototype["toSave"] = function ()
    {
        return {type:'engine'}
    }

    Engine.prototype["setColor"] = function (color)
    {
        Engine.__super__.setColor.call(this,color)
    
        return this.mesh.children[1].material = this.mesh.children[1].material.clone()
    }

    Engine.prototype["setColorByName"] = function (colorName)
    {
        this.colorName = colorName
    
        this.setColor(Colors.train[this.colorName])
        this.mesh.children[2].material = this.mesh.children[2].material.clone()
        this.mesh.children[2].material.emissive.copy(Colors.piston[this.colorName])
        this.mesh.children[3].material = this.mesh.children[3].material.clone()
        return this.mesh.children[3].material.emissive.copy(Colors.piston[this.colorName])
    }

    Engine.prototype["isRearEngine"] = function ()
    {
        return this === this.train.cars.slice(-1)[0]
    }

    Engine.prototype["moveToPathDelta"] = function (path, delta)
    {
        Engine.__super__.moveToPathDelta.call(this,path,delta)
    
        if (this.isRearEngine())
        {
            return this.mesh.rotateY(deg2rad(180))
        }
    }

    Engine.prototype["onEnter"] = function (hit, nextHit, event)
    {
        if (event.buttons === 0)
        {
            if (!this.cargoSelector && !this.body)
            {
                return this.cargoSelector = new CargoSelector(this)
            }
        }
    }

    Engine.prototype["onDrag"] = function (hit, downHit)
    {
        var dist

        if (this.physics)
        {
            return
        }
        dist = hit.point.distanceTo(downHit.point)
        if (dist > 0.5)
        {
            console.log('startDrag!',this.name)
            if (this.isRearEngine())
            {
                this.train.removeCar(this)
                return world.physics.addCar(this)
            }
            else
            {
                return world.physics.addTrain(this.train)
            }
        }
    }

    Engine.prototype["onDragDone"] = function (hit, downHit)
    {
        console.log('drag done!',this.name)
    }

    Engine.prototype["onLeave"] = function (hit, nextHit, event)
    {}

    Engine.prototype["update"] = function (delta, timeSum, train)
    {
        var c, col, sin, x

        if (this.isRearEngine())
        {
            return
        }
        x = 0.2 * Math.sin(2 * timeSum * train.speed * train.advanceFactor)
        this.mesh.children[1].scale.set(1.2 + x,1,1)
        sin = Math.sin(2 * timeSum * train.speed * train.advanceFactor)
        if (sin > 0)
        {
            c = 0.5 + sin
        }
        else
        {
            c = 0.5 + 0.5 * sin
        }
        if (this.colorName)
        {
            col = Colors.piston[this.colorName]
            return this.mesh.children[1].material.emissive.setRGB(col.r * c,col.g * c,col.b * c)
        }
    }

    return Engine
})()

module.exports = Engine