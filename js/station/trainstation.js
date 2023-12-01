// monsterkodi/kode 0.243.0

var _k_ = {extend: function (c,p) {for (var k in p) { if (Object.hasOwn(p, k)) c[k] = p[k] } function ctor() { this.constructor = c; } ctor.prototype = p.prototype; c.prototype = new ctor(); c.__super__ = p.prototype; return c;}, list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}}

var Boxcar, ColorGrid, Engine, GRID_SIZE, Station, Train, TrainStation

ColorGrid = require('../lib/colorgrid')
Station = require('./station')
Engine = require('../train/engine')
Boxcar = require('../train/boxcar')
Train = require('../train/train')
GRID_SIZE = 3

TrainStation = (function ()
{
    _k_.extend(TrainStation, Station)
    function TrainStation (cfg)
    {
        var _20_17_

        this["moveTrain"] = this["moveTrain"].bind(this)
        this["onCentralStorage"] = this["onCentralStorage"].bind(this)
        cfg.name = ((_20_17_=cfg.name) != null ? _20_17_ : `T${Station.id + 1}`)
        TrainStation.__super__.constructor.call(this,cfg)
        this.train = new Train
        this.trainLength = 3
        this.tailEngine = false
        this.building = world.construct.meshes.station.armbase.clone()
        this.building.children[0].material = Materials.station.train
        this.building.position.z = 6
        this.group.add(this.building)
        this.docking = world.construct.meshes.station.docking.clone()
        this.group.add(this.docking)
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
        this.grid = new ColorGrid({gridSize:GRID_SIZE,size:4})
        this.grid.quads.rotateX(deg2rad(90))
        this.grid.quads.position.z = 6 + 2.5
        this.grid.quads.position.y = -2.61
        this.group.add(this.grid.quads)
        this.gridColumns = [[],[],[]]
        post.on('centralStorage',this.onCentralStorage)
    }

    TrainStation.prototype["resourceIndex"] = function (resource)
    {
        return 1 + Object.keys(Colors.mining).indexOf(resource)
    }

    TrainStation.prototype["onCentralStorage"] = function (storage, resource)
    {
        var column, ri

        ri = this.resourceIndex(resource)
        if (this.gridColumns[ri - 1].length < GRID_SIZE)
        {
            this.gridColumns[ri - 1].push(ri)
            this.grid.setColumns(this.gridColumns)
            storage[resource]--
        }
        var list = _k_.list(this.gridColumns)
        for (var _66_19_ = 0; _66_19_ < list.length; _66_19_++)
        {
            column = list[_66_19_]
            if (column.length < GRID_SIZE)
            {
                return
            }
        }
        this.gridColumns = [[],[],[]]
        this.grid.setColumns(this.gridColumns)
        if (this.node.train !== this.train && !this.node.train)
        {
            if (this.nextTrack = this.calcNextTrack())
            {
                this.nextNode = this.nextTrack.nodeOpposite(this.node)
            }
            else
            {
                console.log('no build track!')
                return
            }
        }
        if (this.hasSpaceForCar())
        {
            return this.startCarProduction()
        }
        else
        {
            console.log('no car space!')
        }
    }

    TrainStation.prototype["hasSpaceForCar"] = function ()
    {
        return this.train.cars.length === 0 || this.train.tailDelta() > 2
    }

    TrainStation.prototype["calcNextTrack"] = function ()
    {
        var accum, choice, choices, length, mode, nextNode, nextTrack, nn, nnopptrck, ot, randm, total, trackMode, tracks, _103_59_

        nn = this.node
        ot = (nn.outTracks.length ? nn.outTracks : nn.inTracks)
        mode = (ot === nn.outTracks ? 1 : 2)
        choices = []
        var list = _k_.list(ot)
        for (var _95_22_ = 0; _95_22_ < list.length; _95_22_++)
        {
            nextTrack = list[_95_22_]
            nextNode = nextTrack.nodeOpposite(nn)
            trackMode = nextTrack.modeForNode(nn) || 3
            if (!(mode & trackMode))
            {
                continue
            }
            if (nextTrack.hasExitBlockAtNode(nn))
            {
                continue
            }
            nnopptrck = ((_103_59_=nextNode.oppositeTracks(nextTrack)) != null ? _103_59_ : [])
            if (nnopptrck.length)
            {
                choices.push([nextTrack,nextNode])
            }
        }
        if (choices.length)
        {
            if (choices.length === 1)
            {
                nextTrack = choices[0][0]
                nextNode = choices[0][1]
            }
            else
            {
                tracks = choices.map(function (c)
                {
                    return c[0]
                })
                length = tracks.map(function (t)
                {
                    return t.lastTrainDistance()
                })
                total = 0
                accum = length.map(function (l)
                {
                    return total += l
                })
                randm = randRange(0,total)
                choice = 0
                while (accum[choice] < randm)
                {
                    choice++
                }
                nextTrack = choices[choice][0]
                nextNode = choices[choice][1]
            }
        }
        return nextTrack
    }

    TrainStation.prototype["startCarProduction"] = function ()
    {
        var c, car

        if (this.train.cars.length === 0)
        {
            car = new Engine(this.train)
        }
        else if (this.train.cars.length === this.trainLength - 1 && this.tailEngine)
        {
            car = new Engine(this.train)
        }
        else
        {
            car = new Boxcar(this.train)
        }
        this.train.addCar(car)
        if (this.train.cars.length === 1)
        {
            this.train.path.addTrackNode(this.nextTrack,this.nextNode)
            this.node.setTrain(this.train)
            this.nextTrack.addTrain(this.train)
            this.train.track = this.nextTrack
            car.deadEye()
        }
        else if (this.train.cars.length === this.trainLength)
        {
            this.train.setColorByName(this.train.colorName)
            world.traffic.addTrain(this.train)
            world.physics.addKinematicCar(this.train.cars[0])
            this.train = new Train
            return
        }
        else
        {
            var list = _k_.list(this.train.cars)
            for (var _154_18_ = 0; _154_18_ < list.length; _154_18_++)
            {
                c = list[_154_18_]
                c.deadEye()
            }
        }
        if (!this.movingTrain)
        {
            return world.addAnimation(this.moveTrain)
        }
    }

    TrainStation.prototype["moveTrain"] = function (scaledDelta, timeSum)
    {
        var advance

        advance = world.traffic.allowTrainAdvance(this.train,scaledDelta)
        this.train.advance(advance)
        if (this.train.tailDelta() < 4)
        {
            this.movingTrain = true
            return world.addAnimation(this.moveTrain)
        }
        else
        {
            return this.movingTrain = false
        }
    }

    return TrainStation
})()

module.exports = TrainStation