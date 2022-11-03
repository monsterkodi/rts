// monsterkodi/kode 0.243.0

var _k_ = {assert: function (f,l,c,m,t) { if (!t) {console.log(f + ':' + l + ':' + c + ' ▴ ' + m)}}, list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}, in: function (a,l) {return (typeof l === 'string' && typeof a === 'string' && a.length ? '' : []).indexOf.call(l,a) >= 0}, min: function () { m = Infinity; for (a of arguments) { if (Array.isArray(a)) {m = _k_.min.apply(_k_.min,[m].concat(a))} else {n = parseFloat(a); if(!isNaN(n)){m = n < m ? n : m}}}; return m }, isFunc: function (o) {return typeof o === 'function'}}

var COLLISION_DISTANCE, HEAD_DISTANCE, REAREND_DISTANCE, TAIL_DISTANCE, Traffic

HEAD_DISTANCE = 12
TAIL_DISTANCE = 8
REAREND_DISTANCE = 8
COLLISION_DISTANCE = 4

Traffic = (function ()
{
    function Traffic ()
    {
        this.clear()
    }

    Traffic.prototype["clear"] = function ()
    {
        return this.trains = []
    }

    Traffic.prototype["addTrain"] = function (train)
    {
        return this.trains.push(train)
    }

    Traffic.prototype["subTrain"] = function (train)
    {
        var i, nn, path, pn, tpn

        path = train.path
        if (nn = path.nextNode())
        {
            nn.unblockTrain(train)
            if (nn.train === train)
            {
                nn.unblockAll()
            }
        }
        if (pn = path.prevNode())
        {
            if (pn.train === train)
            {
                pn.unblockAll()
            }
        }
        if (tpn = path.prevNode(train.tailDelta()))
        {
            if (tpn.train === train)
            {
                tpn.unblockAll()
            }
        }
        if ((i = this.trains.indexOf(train)) >= 0)
        {
            return this.trains.splice(i,1)
        }
    }

    Traffic.prototype["simulate"] = function (scaledDelta, timeSum)
    {
        var advance, train

        _k_.assert(".", 50, 8, "assert failed!" + " scaledDelta > 0", scaledDelta > 0)
        this.nodeSignals()
        var list = _k_.list(this.trains)
        for (var _54_18_ = 0; _54_18_ < list.length; _54_18_++)
        {
            train = list[_54_18_]
            advance = scaledDelta * train.speed
            if (advance > 0)
            {
                advance = this.allowTrainAdvance(train,advance)
            }
            if (advance)
            {
                train.advance(advance)
            }
        }
        var list1 = _k_.list(this.trains)
        for (var _62_18_ = 0; _62_18_ < list1.length; _62_18_++)
        {
            train = list1[_62_18_]
            this.pruneTrainPath(train)
            train.update(scaledDelta,timeSum)
        }
    }

    Traffic.prototype["nodeSignals"] = function ()
    {
        var ct, nd, nn, path, tailDelta, tnd, tpd, tpn, train

        var list = _k_.list(this.trains)
        for (var _75_18_ = 0; _75_18_ < list.length; _75_18_++)
        {
            train = list[_75_18_]
            if (path = train.path)
            {
                nd = path.nextDistance()
                if (nd < HEAD_DISTANCE)
                {
                    nn = path.nextNode()
                    if (nn && nn.train !== train)
                    {
                        if (!nn.train)
                        {
                            if (this.trainCanPassThroughNode(train,nn))
                            {
                                nn.setTrain(train)
                            }
                            else
                            {
                                train.block(`cant pass trough ${nn.name}`)
                            }
                        }
                        else
                        {
                            if (!(_k_.in(train,nn.blockedTrains)))
                            {
                                if (path.currentTrack() !== nn.train.tailTrack() && path.currentTrack() !== nn.train.tailPrevTrack() && path.nextTrack() !== nn.train.tailTrack())
                                {
                                    nn.blockTrain(train)
                                }
                                else
                                {
                                    if (path.currentTrack() === nn.train.tailPrevTrack())
                                    {
                                        nn.setTrain(train)
                                    }
                                }
                            }
                        }
                    }
                }
                if (ct = path.currentTrack())
                {
                    if (!ct.hasTrain(train))
                    {
                        train.track.subTrain(train)
                        train.track = ct
                        train.track.addTrain(train)
                    }
                }
                tailDelta = train.tailDelta()
                tpd = path.prevDistance(tailDelta)
                tnd = path.nextDistance(tailDelta)
                if (tpd > _k_.min(TAIL_DISTANCE,tnd + tpd / 2))
                {
                    tpn = path.prevNode(tailDelta)
                    if (tpn.train === train)
                    {
                        tpn.unblockAll()
                    }
                }
            }
        }
    }

    Traffic.prototype["trainCanPassThroughNode"] = function (train, node)
    {
        var nextTrack, nn

        nn = train.nextNode()
        _k_.assert(".", 113, 8, "assert failed!" + " nn === node", nn === node)
        if (nextTrack = this.extendTrainPath(train))
        {
            return nextTrack
        }
    }

    Traffic.prototype["allowTrainAdvance"] = function (train, advance)
    {
        var delta, dist, halfEngineLength, maxAdvance, oldAdvance, other, path, track, trainToOther

        path = train.path
        oldAdvance = advance
        halfEngineLength = 1.9
        maxAdvance = path.getLength() - path.delta - halfEngineLength
        if ((advance > maxAdvance && maxAdvance < 0.0001))
        {
            if (this.extendTrainPath(train))
            {
                return this.allowTrainAdvance(train,advance)
            }
            else
            {
                if (train.isOneWay())
                {
                    return maxAdvance
                }
                else
                {
                    train.reverse()
                    return this.allowTrainAdvance(train,advance)
                }
            }
        }
        advance = Math.min(maxAdvance,advance)
        advance = this.checkCargo(train,advance)
        delta = path.normDelta(path.delta + advance)
        track = path.trackAtDelta(delta)
        var list = _k_.list(this.trains)
        for (var _149_18_ = 0; _149_18_ < list.length; _149_18_++)
        {
            other = list[_149_18_]
            if (other === train)
            {
                continue
            }
            if (other.tailTrack() === track)
            {
                trainToOther = other.tailPrevDistance() - path.prevDistance(delta)
                if (trainToOther >= 0 && trainToOther < REAREND_DISTANCE)
                {
                    advance = 0
                    break
                }
            }
            else if (other.tailPrevTrack() === track)
            {
                trainToOther = other.tailPrevDistance() + path.nextDistance(delta)
                if (trainToOther < REAREND_DISTANCE)
                {
                    advance = 0
                    break
                }
            }
            if (other.headTrack() === track)
            {
                if (path.revers[path.indexAtDelta(delta)] !== other.trackRevers())
                {
                    dist = Math.abs(track.trainCurveDistance(train) - track.trainCurveDistance(other))
                    if (dist < COLLISION_DISTANCE)
                    {
                        console.log('------------------ XXXXXXXXXXXXXX  heads on collision!',train.name,other.name)
                        train.explode()
                        other.explode()
                        advance = 0
                        break
                    }
                }
            }
        }
        train.advanceFactor = advance / oldAdvance
        return advance
    }

    Traffic.prototype["extendTrainPath"] = function (train)
    {
        var accum, choice, choices, length, mode, nextNode, nextTrack, nn, nnopptrck, ot, randm, total, trackMode, tracks, _195_59_

        nn = train.nextNode()
        ot = nn.oppositeTracks(train.currentTrack())
        mode = (ot === nn.outTracks ? 1 : 2)
        choices = []
        var list = _k_.list(ot)
        for (var _187_22_ = 0; _187_22_ < list.length; _187_22_++)
        {
            nextTrack = list[_187_22_]
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
            nnopptrck = ((_195_59_=nextNode.oppositeTracks(nextTrack)) != null ? _195_59_ : [])
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
            train.path.addTrackNode(nextTrack,nextNode)
            return nextTrack
        }
    }

    Traffic.prototype["pruneTrainPath"] = function (train)
    {
        var headIndex, tailDelta, tailIndex

        tailDelta = train.tailDelta()
        tailIndex = train.path.indexAtDelta(tailDelta)
        if (tailIndex > 1)
        {
            headIndex = train.path.currentIndex()
            return train.path.shiftTail()
        }
    }

    Traffic.prototype["checkCargo"] = function (train, advance)
    {
        var car, maxAdvance, minCar, resource, _250_52_, _259_41_, _268_48_

        maxAdvance = advance
        minCar = null
        var list = _k_.list(train.boxcars())
        for (var _245_16_ = 0; _245_16_ < list.length; _245_16_++)
        {
            car = list[_245_16_]
            if (car.isEmpty())
            {
                if (car.waitingForCargo)
                {
                    return 0
                }
                if (resource = (car.nextNode().station != null ? car.nextNode().station.providesCargo() : undefined))
                {
                    if (car.train.resource[resource])
                    {
                        if (car.nextDistance() < maxAdvance)
                        {
                            minCar = car
                            maxAdvance = car.nextDistance()
                        }
                    }
                }
            }
            else
            {
                if (car.waitingForUnload)
                {
                    return 0
                }
                if ((car.nextNode().station != null ? car.nextNode().station.takesCargo() : undefined))
                {
                    if (car.nextDistance() < maxAdvance)
                    {
                        minCar = car
                        maxAdvance = car.nextDistance()
                    }
                }
            }
        }
        if (minCar)
        {
            if (minCar.isEmpty())
            {
                minCar.waitingForCargo = true
                if (!(_k_.isFunc((minCar.nextNode().station != null ? minCar.nextNode().station.carWaitingForCargo : undefined))))
                {
                    console.log('darfuggy?',minCar.nextNode())
                }
                else
                {
                    minCar.nextNode().station.carWaitingForCargo(minCar)
                }
            }
            else
            {
                minCar.waitingForUnload = true
                minCar.nextNode().station.carWaitingForUnload(minCar)
            }
        }
        return maxAdvance
    }

    return Traffic
})()

module.exports = Traffic