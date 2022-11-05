// monsterkodi/kode 0.243.0

var _k_ = {extend: function (c,p) {for (var k in p) { if (Object.hasOwn(p, k)) c[k] = p[k] } function ctor() { this.constructor = c; } ctor.prototype = p.prototype; c.prototype = new ctor(); c.__super__ = p.prototype; return c;}, clamp: function (l,h,v) { var ll = Math.min(l,h), hh = Math.max(l,h); if (!_k_.isNum(v)) { v = ll }; if (v < ll) { v = ll }; if (v > hh) { v = hh }; if (!_k_.isNum(v)) { v = ll }; return v }, list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}, in: function (a,l) {return (typeof l === 'string' && typeof a === 'string' && a.length ? '' : []).indexOf.call(l,a) >= 0}, isNum: function (o) {return !isNaN(o) && !isNaN(parseFloat(o)) && (isFinite(o) || o === Infinity || o === -Infinity)}}

var Boxcar, Compass, Construct, Convert, Engine, Node, Track, Traffic, Train, World

Node = require('./track/node')
Track = require('./track/track')
Train = require('./train/train')
Engine = require('./train/engine')
Boxcar = require('./train/boxcar')
Compass = require('./track/compass')
Construct = require('./construct')
Convert = require('./convert')
Traffic = require('./traffic')

World = (function ()
{
    _k_.extend(World, Convert)
    function World (scene)
    {
        this.scene = scene
    
        this["hideCompass"] = this["hideCompass"].bind(this)
        this.trains = []
        window.world = this
        this.traffic = new Traffic
        this.timeSum = 0
        this.pickables = []
        this.construct = new Construct
        this.construct.init()
        this.compass = new Compass
        this.addFloor()
        this.setSpeed(prefs.get('speed',1))
        return World.__super__.constructor.apply(this, arguments)
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
    {}

    World.prototype["setCamera"] = function (cfg = {dist:10,rotate:45,degree:45})
    {
        var _92_39_, _93_39_, _94_39_, _95_18_

        rts.camera.dist = ((_92_39_=cfg.dist) != null ? _92_39_ : 10)
        rts.camera.rotate = ((_93_39_=cfg.rotate) != null ? _93_39_ : 45)
        rts.camera.degree = ((_94_39_=cfg.degree) != null ? _94_39_ : 45)
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

    World.prototype["animate"] = function (delta)
    {
        var scaledDelta

        scaledDelta = delta * this.speed
        this.timeSum += scaledDelta
        this.simulate(scaledDelta)
        return post.emit('tick')
    }

    World.prototype["simulate"] = function (scaledDelta)
    {
        var train

        this.traffic.simulate(scaledDelta,this.timeSum)
        var list = _k_.list(this.trains)
        for (var _143_18_ = 0; _143_18_ < list.length; _143_18_++)
        {
            train = list[_143_18_]
            train.update(scaledDelta,this.timeSum)
        }
    }

    World.prototype["addFloor"] = function ()
    {
        var geom

        geom = new PlaneGeometry(1500,1500)
        geom.translate(0,0,-0.75)
        this.floor = new Mesh(geom,Materials.floor)
        this.floor.visible = prefs.get('floor')
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

    World.prototype["addTrain"] = function (speed = 1, name = 'train')
    {
        var train

        train = new Train({speed:speed})
        train.name = name
        this.traffic.addTrain(train)
        this.trains.push(train)
        this.addEngine(train)
        return train
    }

    World.prototype["addEngine"] = function (train)
    {
        var engine

        engine = new Engine(this.construct.meshes.engine.clone())
        this.scene.add(engine.mesh)
        this.pickables.push(engine.mesh)
        train.addCar(engine)
        return engine
    }

    World.prototype["addBoxcar"] = function (train, num = 1)
    {
        var boxcar, n

        for (var _202_17_ = n = 0, _202_21_ = num; (_202_17_ <= _202_21_ ? n < num : n > num); (_202_17_ <= _202_21_ ? ++n : --n))
        {
            boxcar = new Boxcar(this.construct.meshes.boxcar.clone())
            this.scene.add(boxcar.mesh)
            this.pickables.push(boxcar.mesh)
            train.addCar(boxcar)
        }
    }

    World.prototype["addNode"] = function (point, name)
    {
        var node

        node = new Node(vec(point),name)
        return node
    }

    World.prototype["connectNodes"] = function (n1, n2, name)
    {
        return this.connectNodeTracks(n1,n1.outTracks,n2,n2.inTracks,name)
    }

    World.prototype["connectNodeTracks"] = function (n1, n1Tracks, n2, n2Tracks, name = `${n1.name} -> ${n2.name}`)
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
        t = this.addTrack(n1,n2,[c1,c2,m,c3,c4],name)
        n1Tracks.push(t)
        n2Tracks.push(t)
        return t
    }

    World.prototype["addTrack"] = function (n1, n2, ctrlPoints, name)
    {
        var index, point, points, track

        points = [n1.getPos()]
        var list = _k_.list(ctrlPoints)
        for (index = 0; index < list.length; index++)
        {
            point = list[index]
            points.push(point)
            if (index % 3 === 2)
            {
                points.push(point)
            }
        }
        points.push(n2.getPos())
        track = new Track(points,name)
        track.node[0] = n1
        track.node[1] = n2
        return track
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

    return World
})()

module.exports = World