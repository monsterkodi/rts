// monsterkodi/kode 0.257.0

var _k_ = {isFunc: function (o) {return typeof o === 'function'}, list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}, in: function (a,l) {return (typeof l === 'string' && typeof a === 'string' && a.length ? '' : []).indexOf.call(l,a) >= 0}, assert: function (f,l,c,m,t) { if (!t) {console.log(f + ':' + l + ':' + c + ' ▴ ' + m)}}}

var Cargo, Immutable, Node, Save, Station, Track, Train

Immutable = require('seamless-immutable')
Node = require('../track/node')
Track = require('../track/track')
Train = require('../train/train')
Station = require('../station/station')
Cargo = require('../station/cargo')

Save = (function ()
{
    function Save ()
    {
        this["onLoad"] = this["onLoad"].bind(this)
        this["onSave"] = this["onSave"].bind(this)
        this.s = Immutable({nodes:{},tracks:{},stations:{},trains:{},ids:{node:0,track:0,train:0,station:0}})
        post.on('save',this.onSave)
        post.on('load',this.onLoad)
        post.on('reload',this.onLoad)
    }

    Save.prototype["onSave"] = function ()
    {
        return prefs.set('save',this.currentState())
    }

    Save.prototype["toNoon"] = function ()
    {
        return noon.stringify(this.currentState(),{circular:true})
    }

    Save.prototype["currentState"] = function ()
    {
        var child, childs, state

        state = {nodes:{},tracks:{},stations:{},trains:{},ids:{node:Node.id,track:Track.id,train:Train.id,station:Station.id}}
        childs = world.scene.children.filter(function (child)
        {
            return _k_.isFunc(child.toSave)
        })
        var list = _k_.list(childs)
        for (var _62_18_ = 0; _62_18_ < list.length; _62_18_++)
        {
            child = list[_62_18_]
            state[child.toSave.key][child.name] = child.toSave()
        }
        this.s = this.s.set('stations',state.stations)
        this.s = this.s.set('nodes',state.nodes)
        this.s = this.s.set('tracks',state.tracks)
        this.s = this.s.set('trains',state.trains)
        return this.s = this.s.set('ids',state.ids)
    }

    Save.prototype["onLoad"] = function ()
    {
        var box, boxcars, c, car, ctrl, i, n1, n2, name, newNoon, node, oldNoon, s, s1, s2, save, station, t, track, train, _102_33_, _105_30_, _107_36_, _113_30_, _115_36_, _126_25_, _141_19_

        save = prefs.get('save')
        if (!save)
        {
            return
        }
        oldNoon = noon.stringify(save,{circular:true})
        world.clear()
        for (name in save.nodes)
        {
            node = save.nodes[name]
            world.addNode(node)
        }
        for (name in save.stations)
        {
            station = save.stations[name]
            s = world.addStation(station)
        }
        for (name in save.tracks)
        {
            track = save.tracks[name]
            n1 = world.nodeWithName(track.node[0])
            n2 = world.nodeWithName(track.node[1])
            ctrl = track.ctrl.map(function (c)
            {
                return vec(c)
            })
            t = world.addTrack(n1,n2,ctrl,name)
            t.setMode(((_102_33_=track.mode) != null ? _102_33_ : 0))
            s1 = save.nodes[n1.name]
            if (_k_.in(name,(((_105_30_=s1.in) != null ? _105_30_ : []))))
            {
                n1.inTracks.push(t)
            }
            else if (_k_.in(name,(((_107_36_=s1.out) != null ? _107_36_ : []))))
            {
                n1.outTracks.push(t)
            }
            else
            {
                console.log('dafuk?',s1,n1)
            }
            s2 = save.nodes[n2.name]
            if (_k_.in(name,(((_113_30_=s2.in) != null ? _113_30_ : []))))
            {
                n2.inTracks.push(t)
            }
            else if (_k_.in(name,(((_115_36_=s2.out) != null ? _115_36_ : []))))
            {
                n2.outTracks.push(t)
            }
            else
            {
                console.log('dafuk?',s2,n2)
            }
        }
        for (name in save.trains)
        {
            train = save.trains[name]
            track = world.trackWithName(train.track)
            node = world.nodeWithName(train.node)
            if ((train.cars != null ? train.cars.length : undefined))
            {
                boxcars = train.cars.filter(function (c)
                {
                    return c.type === 'boxcar'
                }).length
            }
            else
            {
                boxcars = 0
            }
            if (t = world.onAddTrain(track,train.prevDist,node,boxcars,train.name))
            {
                t.resource = train.resource
                if (train.color)
                {
                    t.setColorByName(train.color)
                }
                var list = _k_.list(train.cars)
                for (i = 0; i < list.length; i++)
                {
                    car = list[i]
                    if (car.type === 'boxcar')
                    {
                        if (car.cargo)
                        {
                            c = t.cars[i]
                            _k_.assert(".", 137, 28, "assert failed!" + " c", c)
                            box = new Mesh(Geom.box({size:2}),Materials.mining[car.cargo])
                            c.setCargo(new Cargo(box,car.cargo))
                        }
                    }
                }
            }
        }
        if ((save.ids != null))
        {
            console.log('save.ids',save.ids)
            Node.id = save.ids.node
            Track.id = save.ids.track
            Train.id = save.ids.train
            Station.id = save.ids.station
        }
        newNoon = this.toNoon()
        if (newNoon !== oldNoon)
        {
            console.log('DAFUK?')
        }
    }

    return Save
})()

module.exports = Save