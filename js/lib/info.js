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
        var add, k, node, s, track, train, v, _1_18_, _1_20_, _1_21_, _1_26_, _1_28_, _1_33_, _89_28_, _89_35_

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
            add(`${train.name} ${train.colorName} ${((_1_18_=train.blockReason) != null ? _1_18_ : '')}`)
            add(`   ${train.track.name} ▴ ${train.path.delta.toFixed(1)} td ${train.tailDelta().toFixed(1)}`)
            add(`   hnd ${train.path.nextDistance().toFixed(1)} hpd ${train.headPrevDistance().toFixed(1)} tpd ${train.tailPrevDistance().toFixed(1)}`)
            add(`   htr ${train.headTrack().name} ttr ${train.tailTrack().name}`)
            add(`   tpn ${(train.tailPrevNode() != null ? train.tailPrevNode().name : undefined)} tpt ${((_1_28_=(train.tailPrevTrack() != null ? train.tailPrevTrack().name : undefined)) != null ? _1_28_ : '?')} `)
        }
        add(" ")
        var list1 = _k_.list(world.traffic.trains)
        for (var _65_18_ = 0; _65_18_ < list1.length; _65_18_++)
        {
            train = list1[_65_18_]
            add(`${train.path.toString()}`)
        }
        add = (function (text)
        {
            return elem({class:'infoText',parent:this.track,text:text})
        }).bind(this)
        var list2 = _k_.list(world.allTracks())
        for (var _70_18_ = 0; _70_18_ < list2.length; _70_18_++)
        {
            track = list2[_70_18_]
            s = `${_k_.rpad(4,track.name)} ${track.mode} ${_k_.rpad(4,track.node[0].name)} ▸ ${_k_.rpad(4,track.node[1].name)} ▪ ${_k_.rpad(5,((_1_33_=(track.exitBlockNode != null ? track.exitBlockNode.name : undefined)) != null ? _1_33_ : ''))}`
            var list3 = _k_.list(track.trains)
            for (var _72_22_ = 0; _72_22_ < list3.length; _72_22_++)
            {
                train = list3[_72_22_]
                s += ' ' + _k_.rpad(3,train.name)
            }
            add(s)
        }
        add = (function (text)
        {
            return elem({class:'infoText',parent:this.node,text:text})
        }).bind(this)
        var list4 = _k_.list(world.allNodes())
        for (var _78_17_ = 0; _78_17_ < list4.length; _78_17_++)
        {
            node = list4[_78_17_]
            s = _k_.rpad(5,node.name)
            s += node.commonMode() + ' '
            s += '●'
            var list5 = _k_.list(node.outTracks)
            for (var _82_22_ = 0; _82_22_ < list5.length; _82_22_++)
            {
                track = list5[_82_22_]
                s += ' ' + _k_.rpad(3,track.name)
            }
            s += ' ▴'
            var list6 = _k_.list(node.inTracks)
            for (var _85_22_ = 0; _85_22_ < list6.length; _85_22_++)
            {
                track = list6[_85_22_]
                s += ' ' + _k_.rpad(3,track.name)
            }
            s += ' ▪ '
            s += (((_89_35_=(node.train != null ? node.train.name : undefined)) != null ? _89_35_ : ''))
            s += ' ▪ '
            var list7 = _k_.list(node.blockedTrains)
            for (var _91_22_ = 0; _91_22_ < list7.length; _91_22_++)
            {
                train = list7[_91_22_]
                s += ' ' + _k_.rpad(3,train.name)
            }
            add(s)
        }
    }
}

module.exports = Info