// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}, assert: function (f,l,c,m,t) { if (!t) {console.log(f + ':' + l + ':' + c + ' ▴ ' + m)}}}

var Boxcar, Engine, Path, Train

Path = require('./path')
Engine = require('./engine')
Boxcar = require('./boxcar')

Train = (function ()
{
    Train["carDist"] = 4.2
    Train["numTrains"] = 0
    function Train (cfg)
    {
        var colors, _14_33_, _16_33_

        this.cfg = cfg
    
        this["toSave"] = this["toSave"].bind(this)
        Train.numTrains++
        this.name = (((_14_33_=this.cfg.name) != null ? _14_33_ : "T")) + Train.numTrains
        this.path = new Path(this)
        this.speed = ((_16_33_=this.cfg.speed) != null ? _16_33_ : 1)
        this.topSpeed = this.speed
        this.advanceFactor = 1
        this.cars = []
        this.track = null
        this.resource = {blood:true,water:true,stuff:true}
        this.mesh = new Mesh(Geom.cylinder({radius:0.5,height:0.2}),Materials.train.window)
        this.mesh.train = this
        this.mesh.name = this.name
        this.mesh.visible = false
        this.mesh.toSave = this.toSave
        this.mesh.toSave.key = 'trains'
        colors = Object.keys(Colors.train)
        this.setColorByName(colors[Train.numTrains % colors.length])
        world.addObject(this.mesh)
    }

    Train.prototype["toSave"] = function ()
    {
        var _46_24_

        return {name:this.name,speed:this.speed,track:(this.track != null ? this.track.name : undefined),prevDist:this.path.prevDistance(),node:this.path.nextNode().name,resource:this.resource,path:this.path.toSave(),cars:this.cars.map(function (c)
        {
            return c.toSave()
        })}
    }

    Train.prototype["del"] = function ()
    {
        var car

        this.removeFromTrack()
        var list = _k_.list(this.cars)
        for (var _56_16_ = 0; _56_16_ < list.length; _56_16_++)
        {
            car = list[_56_16_]
            car.del()
        }
        this.cars = []
        return world.removeObject(this.mesh)
    }

    Train.prototype["explode"] = function ()
    {
        this.removeFromTrack()
        return world.physics.addTrain(this)
    }

    Train.prototype["removeFromTrack"] = function ()
    {
        var node, track

        var list = _k_.list(world.allTracks())
        for (var _68_18_ = 0; _68_18_ < list.length; _68_18_++)
        {
            track = list[_68_18_]
            track.onRemoveTrain(this)
        }
        var list1 = _k_.list(world.allNodes())
        for (var _71_17_ = 0; _71_17_ < list1.length; _71_17_++)
        {
            node = list1[_71_17_]
            node.onRemoveTrain(this)
        }
        world.traffic.subTrain(this)
        world.physics.removeKinematicCar(this.cars[0])
        delete this.mesh.toSave
        if (this.track)
        {
            this.track.subTrain(this)
            return this.track = null
        }
    }

    Train.prototype["isOneWay"] = function ()
    {
        return !(this.cars.slice(-1)[0] instanceof Engine)
    }

    Train.prototype["reverse"] = function ()
    {
        var head, tail

        if (!this.isOneWay())
        {
            this.path.delta = this.path.getLength() - this.tailDelta()
            this.path.reverse()
            head = this.cars.shift()
            tail = this.cars.pop()
            this.cars.unshift(tail)
            return this.cars.push(head)
        }
        else
        {
            console.warn('cant reverse oneWay train!')
        }
    }

    Train.prototype["addCar"] = function (car)
    {
        this.cars.push(car)
        car.index = this.cars.length - 1
        car.name = this.name + `.${car.constructor.name[0]}${car.index}`
        car.mesh.name = car.name
        car.setColorByName(this.colorName)
        return car
    }

    Train.prototype["boxcars"] = function ()
    {
        return this.cars.filter(function (c)
        {
            return c instanceof Boxcar
        })
    }

    Train.prototype["setColor"] = function (color)
    {
        var car

        var list = _k_.list(this.cars)
        for (var _116_16_ = 0; _116_16_ < list.length; _116_16_++)
        {
            car = list[_116_16_]
            car.setColor(color)
        }
    }

    Train.prototype["setColorByName"] = function (name)
    {
        var car

        this.colorName = name
        var list = _k_.list(this.cars)
        for (var _122_16_ = 0; _122_16_ < list.length; _122_16_++)
        {
            car = list[_122_16_]
            car.setColorByName(name)
        }
    }

    Train.prototype["block"] = function ()
    {
        return this.speed = 0
    }

    Train.prototype["unblock"] = function ()
    {
        return this.speed = this.topSpeed
    }

    Train.prototype["getLength"] = function ()
    {
        return this.cars.length * Train.carDist
    }

    Train.prototype["carDelta"] = function (car)
    {
        return this.path.normDelta(this.path.delta - Train.carDist * (car.index))
    }

    Train.prototype["tailDelta"] = function ()
    {
        return this.path.normDelta(this.path.delta - Train.carDist * (this.cars.length - 1))
    }

    Train.prototype["headTrack"] = function ()
    {
        return this.path.currentTrack()
    }

    Train.prototype["currentTrack"] = function ()
    {
        return this.path.currentTrack()
    }

    Train.prototype["prevTrack"] = function ()
    {
        return this.path.prevTrack()
    }

    Train.prototype["nextNode"] = function ()
    {
        return this.path.nextNode()
    }

    Train.prototype["tailTrack"] = function ()
    {
        return this.path.trackAtDelta(this.tailDelta())
    }

    Train.prototype["tailPrevTrack"] = function ()
    {
        return this.path.prevTrack(this.tailDelta())
    }

    Train.prototype["tailPrevNode"] = function ()
    {
        return this.path.prevNode(this.tailDelta())
    }

    Train.prototype["tailPrevDistance"] = function ()
    {
        return this.path.prevDistance(this.tailDelta())
    }

    Train.prototype["headPrevDistance"] = function ()
    {
        return this.path.prevDistance()
    }

    Train.prototype["trackRevers"] = function ()
    {
        return this.path.revers[this.path.indexAtDelta()]
    }

    Train.prototype["update"] = function (scaledDelta, timeSum)
    {
        var car, index

        var list = _k_.list(this.cars)
        for (index = 0; index < list.length; index++)
        {
            car = list[index]
            car.update(scaledDelta,timeSum,this)
        }
    }

    Train.prototype["advance"] = function (advance)
    {
        var car, index

        _k_.assert(".", 157, 8, "assert failed!" + " this.path", this.path)
        this.path.advance(advance)
        var list = _k_.list(this.cars)
        for (index = 0; index < list.length; index++)
        {
            car = list[index]
            car.moveToPathDelta(this.path,-Train.carDist * index)
        }
        this.mesh.position.copy(this.cars[0].mesh.position)
        this.mesh.position.z += 1
        return this.mesh.material = this.cars[0].mesh.children[1].material
    }

    return Train
})()

module.exports = Train