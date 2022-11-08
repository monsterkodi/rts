// monsterkodi/kode 0.243.0

var _k_ = {extend: function (c,p) {for (var k in p) { if (Object.hasOwn(p, k)) c[k] = p[k] } function ctor() { this.constructor = c; } ctor.prototype = p.prototype; c.prototype = new ctor(); c.__super__ = p.prototype; return c;}, list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}, assert: function (f,l,c,m,t) { if (!t) {console.log(f + ':' + l + ':' + c + ' ▴ ' + m)}}, clamp: function (l,h,v) { var ll = Math.min(l,h), hh = Math.max(l,h); if (!_k_.isNum(v)) { v = ll }; if (v < ll) { v = ll }; if (v > hh) { v = hh }; if (!_k_.isNum(v)) { v = ll }; return v }, in: function (a,l) {return (typeof l === 'string' && typeof a === 'string' && a.length ? '' : []).indexOf.call(l,a) >= 0}, isNum: function (o) {return !isNaN(o) && !isNaN(parseFloat(o)) && (isFinite(o) || o === Infinity || o === -Infinity)}}

var Boxcar, CentralStation, Compass, Construct, Convert, Engine, MiningStation, Node, Physics, Save, Station, Track, Traffic, Train, TrainStation, World

Node = require('../track/node')
Track = require('../track/track')
Train = require('../train/train')
Engine = require('../train/engine')
Boxcar = require('../train/boxcar')
Compass = require('../track/compass')
Station = require('../station/station')
TrainStation = require('../station/trainstation')
MiningStation = require('../station/miningstation')
CentralStation = require('../station/centralstation')
Construct = require('./construct')
Physics = require('./physics')
Convert = require('./convert')
Traffic = require('./traffic')
Save = require('./save')

World = (function ()
{
    _k_.extend(World, Convert)
    function World (scene)
    {
        this.scene = scene
    
        this["tidyUp"] = this["tidyUp"].bind(this)
        this["delTracks"] = this["delTracks"].bind(this)
        this["delTrains"] = this["delTrains"].bind(this)
        this["onAddTrain"] = this["onAddTrain"].bind(this)
        this["hideCompass"] = this["hideCompass"].bind(this)
        this["setLabels"] = this["setLabels"].bind(this)
        this["getLabels"] = this["getLabels"].bind(this)
        this["toggleLabels"] = this["toggleLabels"].bind(this)
        window.world = this
        this.animations = []
        this.labels = []
        this.pickables = []
        this.timeSum = 0
        this.save = new Save
        this.physics = new Physics
        this.traffic = new Traffic
        this.construct = new Construct
        this.compass = new Compass
        this.construct.init()
        this.addFloor()
        this.setLabels(prefs.get('labels',false))
        this.setSpeed(prefs.get('speed',1))
        post.on('addTrain',this.onAddTrain)
        return World.__super__.constructor.apply(this, arguments)
    }

    World.prototype["addLabel"] = function (cfg)
    {
        var label, _54_34_, _56_45_, _57_32_

        label = new Text()
        label.text = cfg.text
        label.fontSize = ((_54_34_=cfg.size) != null ? _54_34_ : 1)
        label.font = '../pug/' + ((cfg.mono ? 'Meslo.woff' : 'Bahnschrift.woff'))
        label.position.copy(vec(((_56_45_=cfg.position) != null ? _56_45_ : 0)))
        label.color = ((_57_32_=cfg.color) != null ? _57_32_ : 0x9966FF)
        label.anchorX = 'center'
        label.anchorY = 'middle'
        label.noHitTest = true
        label.depthOffset = -0.1
        label.visible = this.getLabels()
        label.sync()
        this.labels.push(label)
        return label
    }

    World.prototype["toggleLabels"] = function ()
    {
        return this.setLabels(!this.getLabels())
    }

    World.prototype["getLabels"] = function ()
    {
        return prefs.get('labels')
    }

    World.prototype["setLabels"] = function (on = true)
    {
        var label

        prefs.set('labels',on)
        var list = _k_.list(this.labels)
        for (var _71_18_ = 0; _71_18_ < list.length; _71_18_++)
        {
            label = list[_71_18_]
            label.visible = on
        }
    }

    World.prototype["addAnimation"] = function (func)
    {
        return this.animations.push(func)
    }

    World.prototype["removeAnimation"] = function (func)
    {
        var index

        if ((index = this.animations.indexOf(func)) >= 0)
        {
            return this.animations.splice(index,1)
        }
    }

    World.prototype["animate"] = function (delta)
    {
        var animation, oldAnimations, scaledDelta

        _k_.assert(".", 91, 8, "assert failed!" + " delta > 0", delta > 0)
        scaledDelta = delta * this.speed
        this.timeSum += scaledDelta
        oldAnimations = this.animations.clone()
        this.animations = []
        var list = _k_.list(oldAnimations)
        for (var _97_22_ = 0; _97_22_ < list.length; _97_22_++)
        {
            animation = list[_97_22_]
            animation(scaledDelta,this.timeSum)
        }
        return this.simulate(scaledDelta)
    }

    World.prototype["showCompass"] = function (object, point, dir)
    {
        var s

        if (object && object !== this.compass.object)
        {
            this.addObject(this.compass.group)
            this.addPickable(this.compass.group)
            this.compass.object = null
            this.compass.group.position.copy(point)
            this.compass.setDir(dir)
            this.compass.object = object
            s = _k_.clamp(1,6,rts.camera.dist / 30)
            return this.compass.group.scale.set(s,s,s)
        }
    }

    World.prototype["hideCompass"] = function (object)
    {
        if (this.compass.object === object || !object && this.compass.object)
        {
            this.removePickable(this.compass.group)
            this.removeObject(this.compass.group)
            return this.compass.object = null
        }
    }

    World.prototype["create"] = function ()
    {}

    World.prototype["clear"] = function ()
    {
        var node, station, track, train

        this.traffic.clear()
        var list = _k_.list(this.allTrains())
        for (var _142_18_ = 0; _142_18_ < list.length; _142_18_++)
        {
            train = list[_142_18_]
            train.del()
        }
        var list1 = _k_.list(this.allStations())
        for (var _145_20_ = 0; _145_20_ < list1.length; _145_20_++)
        {
            station = list1[_145_20_]
            station.del()
        }
        var list2 = _k_.list(this.allNodes())
        for (var _148_17_ = 0; _148_17_ < list2.length; _148_17_++)
        {
            node = list2[_148_17_]
            node.del()
        }
        var list3 = _k_.list(this.allTracks())
        for (var _151_18_ = 0; _151_18_ < list3.length; _151_18_++)
        {
            track = list3[_151_18_]
            track.del()
        }
        return this.physics.clear()
    }

    World.prototype["setCamera"] = function (cfg = {dist:10,rotate:45,degree:45})
    {
        var _164_39_, _165_39_, _166_39_, _167_18_

        rts.camera.dist = ((_164_39_=cfg.dist) != null ? _164_39_ : 10)
        rts.camera.rotate = ((_165_39_=cfg.rotate) != null ? _165_39_ : 45)
        rts.camera.degree = ((_166_39_=cfg.degree) != null ? _166_39_ : 45)
        if ((cfg.pos != null))
        {
            rts.camera.focusOnPoint(vec(cfg.pos))
        }
        else if (cfg.center)
        {
            rts.camera.focusOnPoint(vec(cfg.center))
        }
        return rts.camera.update()
    }

    World.prototype["setSpeed"] = function (speedIndex)
    {
        this.speedIndex = _k_.clamp(0,config.world.speed.length - 1,speedIndex)
        this.speed = config.world.speed[this.speedIndex]
        prefs.set('speed',this.speedIndex)
        return post.emit('worldSpeed',this.speed,this.speedIndex)
    }

    World.prototype["resetSpeed"] = function ()
    {
        return this.setSpeed(2)
    }

    World.prototype["incrSpeed"] = function ()
    {
        return this.setSpeed(this.speedIndex + 1)
    }

    World.prototype["decrSpeed"] = function ()
    {
        return this.setSpeed(this.speedIndex - 1)
    }

    World.prototype["simulate"] = function (scaledDelta)
    {
        this.physics.simulate(scaledDelta,this.timeSum)
        return this.traffic.simulate(scaledDelta,this.timeSum)
    }

    World.prototype["addFloor"] = function ()
    {
        var geom

        geom = new PlaneGeometry(1500,1500)
        geom.translate(0,0,-0.75)
        this.floor = new Mesh(geom,Materials.floor)
        this.floor.name = 'floor'
        this.scene.add(this.floor)
        this.pickables.push(this.floor)
        geom = new PlaneGeometry(1500,1500)
        geom.translate(0,0,0.2 - 0.75)
        this.shadowFloor = new Mesh(geom,Materials.shadow)
        this.shadowFloor.receiveShadow = true
        this.shadowFloor.name = 'shadow'
        return this.scene.add(this.shadowFloor)
    }

    World.prototype["onAddTrain"] = function (track, delta, node, boxcars = 3)
    {
        var train

        track = (track != null ? track : this.cursorTrack)
        if (track && track.node[0] && track.node[1])
        {
            delta = (delta != null ? delta : track.curve.getLength() / 2)
            node = (node != null ? node : track.node[1])
            train = this.addTrain({boxcars:boxcars,traffic:true})
            train.path.addTrackNode(track,node)
            train.path.delta = delta
            train.track = track
            track.addTrain(train)
            if (rts.paused)
            {
                train.advance(0)
            }
            return train
        }
    }

    World.prototype["addTrain"] = function (cfg)
    {
        var engine, i, speed, train, _249_26_

        speed = ((_249_26_=cfg.speed) != null ? _249_26_ : 1)
        train = new Train({speed:speed,name:'T'})
        engine = this.addEngine(train)
        this.physics.addKinematicCar(engine)
        if (cfg.boxcars)
        {
            for (var _257_21_ = i = 0, _257_25_ = cfg.boxcars; (_257_21_ <= _257_25_ ? i < cfg.boxcars : i > cfg.boxcars); (_257_21_ <= _257_25_ ? ++i : --i))
            {
                this.addBoxcar(train)
            }
        }
        if (cfg.rearengine)
        {
            this.addEngine(train)
        }
        if (cfg.traffic)
        {
            this.traffic.addTrain(train)
        }
        return train
    }

    World.prototype["addEngine"] = function (train)
    {
        return train.addCar(new Engine(train))
    }

    World.prototype["addBoxcar"] = function (train, num = 1)
    {
        var boxcar, n

        for (var _276_17_ = n = 0, _276_21_ = num; (_276_17_ <= _276_21_ ? n < num : n > num); (_276_17_ <= _276_21_ ? ++n : --n))
        {
            boxcar = train.addCar(new Boxcar(train))
        }
    }

    World.prototype["delTrains"] = function ()
    {
        var train

        console.log('delTrains')
        var list = _k_.list(this.allTrains())
        for (var _283_18_ = 0; _283_18_ < list.length; _283_18_++)
        {
            train = list[_283_18_]
            train.del()
        }
    }

    World.prototype["addNode"] = function (cfg)
    {
        return new Node(cfg)
    }

    World.prototype["allNodes"] = function ()
    {
        return this.scene.children.filter(function (child)
        {
            return child.node instanceof Node
        }).map(function (child)
        {
            return child.node
        })
    }

    World.prototype["allTracks"] = function ()
    {
        return this.scene.children.filter(function (child)
        {
            return child.track instanceof Track
        }).map(function (child)
        {
            return child.track
        })
    }

    World.prototype["allStations"] = function ()
    {
        return this.scene.children.filter(function (child)
        {
            return child.station instanceof Station
        }).map(function (child)
        {
            return child.station
        })
    }

    World.prototype["allTrains"] = function ()
    {
        return this.scene.children.filter(function (child)
        {
            return child.train instanceof Train
        }).map(function (child)
        {
            return child.train
        })
    }

    World.prototype["nodeWithName"] = function (name)
    {
        var node

        var list = _k_.list(this.allNodes())
        for (var _300_17_ = 0; _300_17_ < list.length; _300_17_++)
        {
            node = list[_300_17_]
            if (node.name === name)
            {
                return node
            }
        }
    }

    World.prototype["trackWithName"] = function (name)
    {
        var track

        var list = _k_.list(this.allTracks())
        for (var _304_18_ = 0; _304_18_ < list.length; _304_18_++)
        {
            track = list[_304_18_]
            if (track.name === name)
            {
                return track
            }
        }
    }

    World.prototype["connectNodes"] = function (n1, n2)
    {
        return this.connectNodeTracks(n1,n1.outTracks,n2,n2.inTracks)
    }

    World.prototype["connectNodeTracks"] = function (n1, n1Tracks, n2, n2Tracks)
    {
        var c1, c2, c3, c4, d1, d2, f, m, s, t

        s = n1.getPos().distanceTo(n2.getPos())
        s *= 0.5
        d1 = n1.getDir()
        d1.scale(s)
        if (n1Tracks !== n1.outTracks)
        {
            d1.negate()
        }
        d1.add(n1.getPos())
        d2 = n2.getDir()
        d2.scale(s)
        if (n2Tracks !== n2.outTracks)
        {
            d2.negate()
        }
        d2.add(n2.getPos())
        m = Vector.midPoint(d1,d2)
        f = 0.553
        c1 = Vector.midPoint(n1.getPos(),d1,f)
        c2 = Vector.midPoint(m,d1,f)
        c3 = Vector.midPoint(m,d2,f)
        c4 = Vector.midPoint(n2.getPos(),d2,f)
        t = this.addTrack(n1,n2,[c1,c2,m,c3,c4])
        n1Tracks.push(t)
        n2Tracks.push(t)
        return t
    }

    World.prototype["addTrack"] = function (n1, n2, ctrlPoints, name)
    {
        var track

        track = new Track(n1,n2,ctrlPoints,name)
        return track
    }

    World.prototype["delTracks"] = function ()
    {
        var node, track

        console.log('delTracks')
        this.delTrains()
        var list = _k_.list(this.allTracks())
        for (var _350_18_ = 0; _350_18_ < list.length; _350_18_++)
        {
            track = list[_350_18_]
            track.del()
        }
        var list1 = _k_.list(this.allNodes())
        for (var _352_17_ = 0; _352_17_ < list1.length; _352_17_++)
        {
            node = list1[_352_17_]
            if (!node.fixed)
            {
                node.del()
            }
        }
    }

    World.prototype["addCentralStation"] = function (cfg)
    {
        return new CentralStation(cfg)
    }

    World.prototype["addMiningStation"] = function (cfg)
    {
        return new MiningStation(cfg)
    }

    World.prototype["addTrainStation"] = function (cfg)
    {
        return new TrainStation(cfg)
    }

    World.prototype["addStation"] = function (cfg)
    {
        switch (cfg.name[0])
        {
            case 'M':
                return this.addMiningStation(cfg)

            case 'C':
                return this.addCentralStation(cfg)

            case 'T':
                return this.addTrainStation(cfg)

        }

    }

    World.prototype["indexToPos"] = function (index, pos)
    {
        pos.x = (index & 0b11111111) - 128
        pos.y = ((index >> 8) & 0b11111111) - 128
        pos.z = ((index >> 16) & 0b11111111) - 128
        return pos
    }

    World.prototype["invalidPos"] = function (pos)
    {
        return !this.validPos(pos)
    }

    World.prototype["validPos"] = function (pos)
    {
        if (pos.x > 127 || pos.x < -127)
        {
            return false
        }
        if (pos.y > 127 || pos.y < -127)
        {
            return false
        }
        if (pos.z > 127 || pos.z < -127)
        {
            return false
        }
        return true
    }

    World.prototype["roundPos"] = function (v)
    {
        Vector.tmp.copy(v)
        return Vector.tmp.rounded()
    }

    World.prototype["addPickable"] = function (mesh)
    {
        if (!(_k_.in(mesh,this.pickables)))
        {
            return this.pickables.push(mesh)
        }
    }

    World.prototype["removePickable"] = function (mesh)
    {
        if (_k_.in(mesh,this.pickables))
        {
            return this.pickables.splice(this.pickables.indexOf(mesh),1)
        }
    }

    World.prototype["addObject"] = function (mesh)
    {
        return this.scene.add(mesh)
    }

    World.prototype["removeObject"] = function (mesh)
    {
        return mesh.removeFromParent()
    }

    World.prototype["addBody"] = function (body)
    {
        return this.physics.addBody(body)
    }

    World.prototype["removeBody"] = function (body)
    {
        if (body)
        {
            return this.physics.removeBody(body)
        }
    }

    World.prototype["tidyUp"] = function ()
    {
        return this.physics.clear()
    }

    return World
})()

module.exports = World