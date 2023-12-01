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
        this.paths = elem({class:'info',style:'bottom:10px; left:700px;'})
        this.station = elem({class:'info',style:'top:40px; left:700px;'})
        this.node = elem({class:'info',style:'bottom:10px; left:350px;'})
        document.body.appendChild(this.info)
        document.body.appendChild(this.train)
        document.body.appendChild(this.track)
        document.body.appendChild(this.paths)
        document.body.appendChild(this.station)
        document.body.appendChild(this.node)
    }

    del ()
    {
        this.info.remove()
        this.train.remove()
        this.track.remove()
        this.paths.remove()
        this.station.remove()
        return this.node.remove()
    }

    draw (info)
    {
        var add, car, corpses, k, node, s, station, track, train, v, _1_11_, _1_18_, _1_25_, _1_26_, _1_33_, _109_28_, _109_35_

        this.info.innerHTML = ''
        this.train.innerHTML = ''
        this.track.innerHTML = ''
        this.paths.innerHTML = ''
        this.station.innerHTML = ''
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
        corpses = world.allTrains().length - world.traffic.trains.length
        add(`bodies  ${world.physics.cannon.bodies.length}`)
        add(`corpses ${corpses}`)
        add(`trains  ${world.traffic.trains.length}`)
        add(`tracks  ${world.allTracks().length}`)
        add(`nodes   ${world.allNodes().length}`)
        add = (function (text)
        {
            return elem({class:'infoText',parent:this.station,text:text})
        }).bind(this)
        var list = _k_.list(world.allStations())
        for (var _64_20_ = 0; _64_20_ < list.length; _64_20_++)
        {
            station = list[_64_20_]
            add(`${_k_.rpad(5,station.name)} ${((_1_25_=(station.waitingCar != null ? station.waitingCar.name : undefined)) != null ? _1_25_ : '')} ${((station.arm != null ? station.arm.waitingForCar : undefined) ? 'waiting' : '')}`)
        }
        add = (function (text)
        {
            return elem({class:'infoText',parent:this.train,text:text})
        }).bind(this)
        var list1 = _k_.list(world.traffic.trains)
        for (var _69_18_ = 0; _69_18_ < list1.length; _69_18_++)
        {
            train = list1[_69_18_]
            add(`${train.name} ${train.colorName} ${((_1_18_=train.blockReason) != null ? _1_18_ : '')}`)
            add(`   ${train.track.name} ▴ ${train.path.delta.toFixed(1)} td ${train.tailDelta().toFixed(1)}`)
            var list2 = _k_.list(train.boxcars())
            for (var _75_20_ = 0; _75_20_ < list2.length; _75_20_++)
            {
                car = list2[_75_20_]
                if (car.waitingForUnload || car.waitingForLoad)
                {
                    add(`   ${car.name} ${(car.waitingForUnload ? 'unload' : '')} ${(car.waitingForCargo ? 'cargo' : '')}`)
                }
            }
        }
        add(" ")
        add = (function (text)
        {
            return elem({class:'infoText',parent:this.paths,text:text})
        }).bind(this)
        var list3 = _k_.list(world.traffic.trains)
        for (var _82_18_ = 0; _82_18_ < list3.length; _82_18_++)
        {
            train = list3[_82_18_]
            add(`${train.path.toString()}`)
        }
        add = (function (text)
        {
            return elem({class:'infoText',parent:this.track,text:text})
        }).bind(this)
        var list4 = _k_.list(world.allTracks())
        for (var _87_18_ = 0; _87_18_ < list4.length; _87_18_++)
        {
            track = list4[_87_18_]
            s = `${_k_.rpad(4,track.name)} ${track.mode} ${_k_.rpad(4,track.node[0].name)} ▸ ${_k_.rpad(4,track.node[1].name)} ▪ ${_k_.rpad(5,((_1_33_=(track.exitBlockNode != null ? track.exitBlockNode.name : undefined)) != null ? _1_33_ : ''))}`
            var list5 = _k_.list(track.trains)
            for (var _89_22_ = 0; _89_22_ < list5.length; _89_22_++)
            {
                train = list5[_89_22_]
                s += ' ' + _k_.rpad(3,train.name)
            }
            s += " ▪▪ "
            var list6 = _k_.list(track.exitBlockTrains)
            for (var _92_22_ = 0; _92_22_ < list6.length; _92_22_++)
            {
                train = list6[_92_22_]
                s += ' ' + _k_.rpad(3,train.name)
            }
            add(s)
        }
        add = (function (text)
        {
            return elem({class:'infoText',parent:this.node,text:text})
        }).bind(this)
        var list7 = _k_.list(world.allNodes())
        for (var _98_17_ = 0; _98_17_ < list7.length; _98_17_++)
        {
            node = list7[_98_17_]
            s = _k_.rpad(5,node.name)
            s += node.commonMode() + ' '
            s += '●'
            var list8 = _k_.list(node.outTracks)
            for (var _102_22_ = 0; _102_22_ < list8.length; _102_22_++)
            {
                track = list8[_102_22_]
                s += ' ' + _k_.rpad(3,track.name)
            }
            s += ' ▴'
            var list9 = _k_.list(node.inTracks)
            for (var _105_22_ = 0; _105_22_ < list9.length; _105_22_++)
            {
                track = list9[_105_22_]
                s += ' ' + _k_.rpad(3,track.name)
            }
            s += ' ▪ '
            s += (((_109_35_=(node.train != null ? node.train.name : undefined)) != null ? _109_35_ : ''))
            s += ' ▪ '
            var list10 = _k_.list(node.blockedTrains)
            for (var _111_22_ = 0; _111_22_ < list10.length; _111_22_++)
            {
                train = list10[_111_22_]
                s += ' ' + _k_.rpad(3,train.name)
            }
            add(s)
        }
    }
}

module.exports = Info