// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}, rpad: function (l,s='',c=' ') {s=String(s); while(s.length<l){s+=c} return s}}

class Info
{
    constructor ()
    {
        this.draw = this.draw.bind(this)
        this.info = elem({class:'info',style:'bottom:10px; right:20px;'})
        this.train = elem({class:'info',style:'top:40px; left:20px;'})
        this.track = elem({class:'info',style:'top:40px; left:350px;'})
        this.node = elem({class:'info',style:'bottom:10px; left:350px;'})
        document.body.appendChild(this.info)
        document.body.appendChild(this.train)
        document.body.appendChild(this.track)
        document.body.appendChild(this.node)
    }

    del ()
    {
        this.info.remove()
        this.train.remove()
        this.track.remove()
        return this.node.remove()
    }

    draw (info)
    {
        var add, k, node, s, track, train, v, _1_17_, _1_20_, _1_21_, _93_28_, _93_35_

        this.info.innerHTML = ''
        this.train.innerHTML = ''
        this.track.innerHTML = ''
        this.node.innerHTML = ''
        add = (function (text)
        {
            return elem({class:'infoText',parent:this.info,text:text})
        }).bind(this)
        for (k in info)
        {
            v = info[k]
            add(`${k} ${v}`)
        }
        add = (function (text)
        {
            return elem({class:'infoText',parent:this.train,text:text})
        }).bind(this)
        var list = _k_.list(world.traffic.trains)
        for (var _49_18_ = 0; _49_18_ < list.length; _49_18_++)
        {
            train = list[_49_18_]
            add(`${train.name}`)
            add(`   track  ${train.track.name}`)
            add(`   delta  ${train.path.delta.toFixed(1)}`)
            add(`   tail   ${train.tailDelta().toFixed(1)}`)
            add(`   length ${train.path.getLength().toFixed(1)}`)
            add(`   hnd    ${train.path.nextDistance().toFixed(1)}`)
            add(`   hpd    ${train.headPrevDistance().toFixed(1)}`)
            add(`   tpd    ${train.tailPrevDistance().toFixed(1)}`)
            add(`   headTrack ${train.headTrack().name}`)
            add(`   prevTrack ${(train.prevTrack() != null ? train.prevTrack().name : undefined)}`)
            add(`   tailTrack ${train.tailTrack().name}`)
            add(`   prevTailTrack ${(train.tailPrevTrack() != null ? train.tailPrevTrack().name : undefined)}`)
            add(`   tailPrevNode ${(train.tailPrevNode() != null ? train.tailPrevNode().name : undefined)}`)
            add(`${train.path.toString()}`)
        }
        add = (function (text)
        {
            return elem({class:'infoText',parent:this.track,text:text})
        }).bind(this)
        var list1 = _k_.list(world.allTracks())
        for (var _74_18_ = 0; _74_18_ < list1.length; _74_18_++)
        {
            track = list1[_74_18_]
            s = `${_k_.rpad(3,track.name)}    ${track.mode} ${_k_.rpad(4,track.node[0].name)} ▸ ${_k_.rpad(4,track.node[1].name)}`
            var list2 = _k_.list(track.trains)
            for (var _76_22_ = 0; _76_22_ < list2.length; _76_22_++)
            {
                train = list2[_76_22_]
                s += ' ' + _k_.rpad(3,train.name)
            }
            add(s)
        }
        add = (function (text)
        {
            return elem({class:'infoText',parent:this.node,text:text})
        }).bind(this)
        var list3 = _k_.list(world.allNodes())
        for (var _82_17_ = 0; _82_17_ < list3.length; _82_17_++)
        {
            node = list3[_82_17_]
            s = _k_.rpad(5,node.name)
            s += node.commonMode() + ' '
            s += '●'
            var list4 = _k_.list(node.outTracks)
            for (var _86_22_ = 0; _86_22_ < list4.length; _86_22_++)
            {
                track = list4[_86_22_]
                s += ' ' + _k_.rpad(3,track.name)
            }
            s += ' ▴'
            var list5 = _k_.list(node.inTracks)
            for (var _89_22_ = 0; _89_22_ < list5.length; _89_22_++)
            {
                track = list5[_89_22_]
                s += ' ' + _k_.rpad(3,track.name)
            }
            s += ' ▪ '
            s += (((_93_35_=(node.train != null ? node.train.name : undefined)) != null ? _93_35_ : ''))
            s += ' ▪ '
            var list6 = _k_.list(node.blockedTrains)
            for (var _95_22_ = 0; _95_22_ < list6.length; _95_22_++)
            {
                train = list6[_95_22_]
                s += ' ' + _k_.rpad(3,train.name)
            }
            add(s)
        }
    }
}

module.exports = Info