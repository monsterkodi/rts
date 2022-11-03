// monsterkodi/kode 0.243.0

var _k_ = {in: function (a,l) {return (typeof l === 'string' && typeof a === 'string' && a.length ? '' : []).indexOf.call(l,a) >= 0}, assert: function (f,l,c,m,t) { if (!t) {console.log(f + ':' + l + ':' + c + ' ▴ ' + m)}}, list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}, clamp: function (l,h,v) { var ll = Math.min(l,h), hh = Math.max(l,h); if (!_k_.isNum(v)) { v = ll }; if (v < ll) { v = ll }; if (v > hh) { v = hh }; if (!_k_.isNum(v)) { v = ll }; return v }, isNum: function (o) {return !isNaN(o) && !isNaN(parseFloat(o)) && (isFinite(o) || o === Infinity || o === -Infinity)}}

var Path


Path = (function ()
{
    function Path (train)
    {
        this.train = train
    
        this["onDelNode"] = this["onDelNode"].bind(this)
        this["onDelTrack"] = this["onDelTrack"].bind(this)
        this.name = this.train.name + '.path'
        this.delta = 0
        this.tracks = []
        this.nodes = []
        this.revers = []
        post.on('delTrack',this.onDelTrack)
        post.on('delNode',this.onDelNode)
    }

    Path.prototype["del"] = function ()
    {
        this.train.explode()
        return delete this.train.path
    }

    Path.prototype["toSave"] = function ()
    {
        return {delta:this.delta,tracks:this.tracks.map(function (t)
        {
            return t.name
        }),nodes:this.nodes.map(function (n)
        {
            return n.name
        }),revers:this.revers}
    }

    Path.prototype["toString"] = function ()
    {
        var i, s

        s = this.train.name
        for (var _36_17_ = i = 0, _36_21_ = this.tracks.length; (_36_17_ <= _36_21_ ? i < this.tracks.length : i > this.tracks.length); (_36_17_ <= _36_21_ ? ++i : --i))
        {
            s += ' ➜ '
            s += this.tracks[i].name
            if (this.revers[i])
            {
                s += ' ◂ ' + this.nodes[i].name
            }
            else
            {
                s += ' ▸ ' + this.nodes[i].name
            }
        }
        return s
    }

    Path.prototype["reverse"] = function ()
    {
        this.tracks.reverse()
        this.revers.reverse()
        this.revers = this.revers.map(function (r)
        {
            return !r
        })
        this.nodes.reverse()
        this.nodes.shift()
        return this.nodes.push(this.tracks.slice(-1)[0].node[(this.revers.slice(-1)[0] ? 0 : 1)])
    }

    Path.prototype["onDelTrack"] = function (track)
    {
        var _61_48_, _61_55_

        if (_k_.in(track,this.tracks))
        {
            _k_.assert(".", 58, 12, "assert failed!" + " track !== this.train.track", track !== this.train.track)
            _k_.assert(".", 59, 12, "assert failed!" + " this.currentTrack() === this.train.track", this.currentTrack() === this.train.track)
            if (this.currentTrack() !== this.train.track)
            {
                console.log(this.currentTrack().name,((_61_48_=this.train) != null ? (_61_55_=_61_48_.track) != null ? _61_55_.name : undefined : undefined))
                return
            }
            this.delta = this.prevDistance()
            this.tracks = [this.currentTrack()]
            this.nodes = [this.nextNode()]
            return this.revers = [this.tracks[0].node[1] !== this.nodes[0]]
        }
    }

    Path.prototype["onDelNode"] = function (node)
    {
        var i

        while ((i = this.nodes.indexOf(node)) >= 0)
        {
            this.nodes.splice(i,1)
        }
    }

    Path.prototype["addTrackNode"] = function (track, node)
    {
        this.nodes.push(node)
        this.tracks.push(track)
        return this.revers.push(track.node[0] === node)
    }

    Path.prototype["shiftTail"] = function ()
    {
        _k_.assert(".", 81, 8, "assert failed!" + " this.tracks.length > 1", this.tracks.length > 1)
        this.delta -= this.deltaAtIndex(1)
        this.nodes.shift()
        this.tracks.shift()
        return this.revers.shift()
    }

    Path.prototype["getLength"] = function ()
    {
        var cd, ti

        cd = 0
        for (var _90_18_ = ti = 0, _90_22_ = this.tracks.length; (_90_18_ <= _90_22_ ? ti < this.tracks.length : ti > this.tracks.length); (_90_18_ <= _90_22_ ? ++ti : --ti))
        {
            if (this.tracks[ti].curve)
            {
                cd += this.tracks[ti].curve.getLength()
            }
            else
            {
                console.log('dafuk?',this.name,ti,this.tracks[ti])
            }
        }
        return cd
    }

    Path.prototype["deltaAtIndex"] = function (index)
    {
        var cd, ti

        if (index >= this.tracks.length)
        {
            return this.getLength()
        }
        if (index <= 0)
        {
            return 0
        }
        cd = 0
        for (var _101_18_ = ti = 0, _101_22_ = index; (_101_18_ <= _101_22_ ? ti < index : ti > index); (_101_18_ <= _101_22_ ? ++ti : --ti))
        {
            if (this.tracks[ti].curve)
            {
                cd += this.tracks[ti].curve.getLength()
            }
            else
            {
                console.log('dafuk?',this.name,ti,this.tracks[ti])
            }
        }
        return cd
    }

    Path.prototype["indexAtDelta"] = function (d = this.delta)
    {
        var cd, i, nd, t

        nd = this.normDelta(d)
        cd = 0
        var list = _k_.list(this.tracks)
        for (i = 0; i < list.length; i++)
        {
            t = list[i]
            if (t.curve)
            {
                cd += t.curve.getLength()
            }
            else
            {
                console.log('dafuk?',this.name,i,t)
            }
            if (cd >= nd)
            {
                return i
            }
        }
        console.log('dafuk?',this.name,d,nd,cd)
    }

    Path.prototype["nodeAtDelta"] = function (d = this.delta)
    {
        return this.nodes[this.indexAtDelta(d)]
    }

    Path.prototype["curveAtDelta"] = function (d = this.delta)
    {
        return this.tracks[this.indexAtDelta(d)].curve
    }

    Path.prototype["posAtDelta"] = function (d = this.delta)
    {
        var di, i, nd, p, restDelta, t

        nd = this.normDelta(d)
        di = this.indexAtDelta(nd)
        restDelta = nd - this.deltaAtIndex(di)
        if (restDelta < 0)
        {
            console.log('darfugg?')
        }
        else if (restDelta - this.tracks[di].curve.getLength() > 0.001)
        {
            var list = _k_.list(this.tracks)
            for (i = 0; i < list.length; i++)
            {
                t = list[i]
                console.log(i,t.curve.getLength(),this.deltaAtIndex(i))
            }
            console.log('aertfsf?',restDelta,di,this.tracks.length,this.tracks[di].curve.getLength())
        }
        p = restDelta / this.tracks[di].curve.getLength()
        if (this.revers[di])
        {
            p = 1 - p
        }
        return _k_.clamp(0,1,p)
    }

    Path.prototype["currentIndex"] = function ()
    {
        return this.indexAtDelta(this.delta)
    }

    Path.prototype["nextNode"] = function (d = this.delta)
    {
        return this.nodes[this.indexAtDelta(d)]
    }

    Path.prototype["prevNode"] = function (d = this.delta)
    {
        var di

        di = this.indexAtDelta(d)
        if (di === 0)
        {
            return this.tracks[0].node[(this.revers[0] ? 1 : 0)]
        }
        else
        {
            return this.nodes[di - 1]
        }
    }

    Path.prototype["prevTrack"] = function ()
    {
        return this.tracks[this.currentIndex() - 1]
    }

    Path.prototype["currentTrack"] = function ()
    {
        return this.tracks[this.currentIndex()]
    }

    Path.prototype["nextTrack"] = function ()
    {
        return this.tracks[this.currentIndex() + 1]
    }

    Path.prototype["trackAtDelta"] = function (d = this.delta)
    {
        return this.tracks[this.indexAtDelta(d)]
    }

    Path.prototype["currentCurve"] = function ()
    {
        return this.currentTrack().curve
    }

    Path.prototype["currentPos"] = function ()
    {
        return this.posAtDelta(this.delta)
    }

    Path.prototype["nextDistance"] = function (d = this.delta)
    {
        return this.deltaAtIndex(this.indexAtDelta(d) + 1) - d
    }

    Path.prototype["prevDistance"] = function (d = this.delta)
    {
        return d - this.deltaAtIndex(this.indexAtDelta(d))
    }

    Path.prototype["advance"] = function (delta)
    {
        return this.delta = this.normDelta(this.delta + delta)
    }

    Path.prototype["getPoint"] = function (point, offset = 0)
    {
        var d, u

        d = this.normDelta(this.delta + offset)
        u = this.posAtDelta(d)
        _k_.assert(".", 164, 8, "assert failed!" + " (0 <= u && u <= 1)", (0 <= u && u <= 1))
        return this.curveAtDelta(d).getPointAt(u,point)
    }

    Path.prototype["getTangent"] = function (point, offset = 0)
    {
        var c, d, p

        d = this.normDelta(this.delta + offset)
        p = this.posAtDelta(d)
        c = this.curveAtDelta(d)
        if (!point)
        {
            console.log('darfugg?')
            return vec(0,1,0)
        }
        if (!c)
        {
            console.log('DARKFUG?')
            return vec(0,1,0)
        }
        _k_.assert(".", 177, 8, "assert failed!" + " (0 <= p && p <= 1)", (0 <= p && p <= 1))
        try
        {
            c.getTangentAt(p,point)
        }
        catch (err)
        {
            console.error('ERROR!',err)
            return vec(0,1,0)
        }
        if (this.revers[this.indexAtDelta(d)])
        {
            return point.multiplyScalar(-1)
        }
    }

    Path.prototype["moveMesh"] = function (mesh, offset)
    {
        this.getPoint(mesh.position,offset)
        this.getTangent(Vector.tmp,offset)
        Vector.tmp.add(mesh.position)
        mesh.up.set(0,0,1)
        mesh.lookAt(Vector.tmp)
        return mesh.position.add(vec(mesh.up).scale(0.85))
    }

    Path.prototype["normDelta"] = function (d)
    {
        var length

        length = this.getLength()
        if (!length)
        {
            return 0
        }
        return (d + 10 * length) % length
    }

    return Path
})()

module.exports = Path