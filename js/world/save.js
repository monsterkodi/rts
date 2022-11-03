// monsterkodi/kode 0.243.0

var _k_ = {isFunc: function (o) {return typeof o === 'function'}, list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}, in: function (a,l) {return (typeof l === 'string' && typeof a === 'string' && a.length ? '' : []).indexOf.call(l,a) >= 0}, assert: function (f,l,c,m,t) { if (!t) {console.log(f + ':' + l + ':' + c + ' ▴ ' + m)}}}

var Cargo, Immutable, Save

Immutable = require('seamless-immutable')
Cargo = require('../station/cargo')

Save = (function ()
{
    function Save ()
    {
        this["onLoad"] = this["onLoad"].bind(this)
        this["onSave"] = this["onSave"].bind(this)
        this.s = Immutable({nodes:{},tracks:{},stations:{},trains:{}})
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

        state = {nodes:{},tracks:{},stations:{},trains:{}}
        childs = world.scene.children.filter(function (child)
        {
            return _k_.isFunc(child.toSave)
        })
        var list = _k_.list(childs)
        for (var _48_18_ = 0; _48_18_ < list.length; _48_18_++)
        {
            child = list[_48_18_]
            state[child.toSave.key][child.name] = child.toSave()
        }
        this.s = this.s.set('stations',state.stations)
        this.s = this.s.set('nodes',state.nodes)
        this.s = this.s.set('tracks',state.tracks)
        return this.s = this.s.set('trains',state.trains)
    }

    Save.prototype["onLoad"] = function ()
    {
        var box, boxcars, c, car, ctrl, i, n1, n2, name, newNoon, node, oldNoon, s, s1, s2, save, station, t, track, train, _100_36_, _87_33_, _90_30_, _92_36_, _98_30_

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
            t.setMode(((_87_33_=track.mode) != null ? _87_33_ : 0))
            s1 = save.nodes[n1.name]
            if (_k_.in(name,(((_90_30_=s1.in) != null ? _90_30_ : []))))
            {
                n1.inTracks.push(t)
            }
            else if (_k_.in(name,(((_92_36_=s1.out) != null ? _92_36_ : []))))
            {
                n1.outTracks.push(t)
            }
            else
            {
                console.log('dafuk?',s1,n1)
            }
            s2 = save.nodes[n2.name]
            if (_k_.in(name,(((_98_30_=s2.in) != null ? _98_30_ : []))))
            {
                n2.inTracks.push(t)
            }
            else if (_k_.in(name,(((_100_36_=s2.out) != null ? _100_36_ : []))))
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
            console.log(train)
            track = world.trackWithName(train.track)
            node = world.nodeWithName(train.node)
            boxcars = train.cars.filter(function (c)
            {
                return c.type === 'boxcar'
            }).length
            if (t = world.onAddTrain(track,train.prevDist,node,boxcars))
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
                            _k_.assert(".", 119, 28, "assert failed!" + " c", c)
                            box = new Mesh(Geom.box({size:2}),Materials.mining[car.cargo])
                            c.setCargo(new Cargo(box,car.cargo))
                        }
                    }
                }
            }
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