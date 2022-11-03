// monsterkodi/kode 0.243.0

var _k_ = {assert: function (f,l,c,m,t) { if (!t) {console.log(f + ':' + l + ':' + c + ' ▴ ' + m)}}, list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}, in: function (a,l) {return (typeof l === 'string' && typeof a === 'string' && a.length ? '' : []).indexOf.call(l,a) >= 0}, min: function () { m = Infinity; for (a of arguments) { if (Array.isArray(a)) {m = _k_.min.apply(_k_.min,[m].concat(a))} else {n = parseFloat(a); if(!isNaN(n)){m = n < m ? n : m}}}; return m }, isFunc: function (o) {return typeof o === 'function'}}

var HEAD_DISTANCE, REAREND_DISTANCE, TAIL_DISTANCE, Traffic

HEAD_DISTANCE = 12
TAIL_DISTANCE = 8
REAREND_DISTANCE = 8

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

        _k_.assert(".", 49, 8, "assert failed!" + " scaledDelta > 0", scaledDelta > 0)
        this.nodeSignals()
        var list = _k_.list(this.trains)
        for (var _53_18_ = 0; _53_18_ < list.length; _53_18_++)
        {
            train = list[_53_18_]
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
        for (var _61_18_ = 0; _61_18_ < list1.length; _61_18_++)
        {
            train = list1[_61_18_]
            this.pruneTrainPath(train)
            train.update(scaledDelta,timeSum)
        }
    }

    Traffic.prototype["nodeSignals"] = function ()
    {
        var ct, nd, nn, path, tailDelta, tnd, tpd, tpn, train

        var list = _k_.list(this.trains)
        for (var _74_18_ = 0; _74_18_ < list.length; _74_18_++)
        {
            train = list[_74_18_]
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
        _k_.assert(".", 112, 8, "assert failed!" + " nn === node", nn === node)
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
        for (var _148_18_ = 0; _148_18_ < list.length; _148_18_++)
        {
            other = list[_148_18_]
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
                    if (dist < 4.5)
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
        var mode, nextNode, nextTrack, nn, nnopptrck, ot, trackMode, _192_59_

        nn = train.nextNode()
        ot = nn.oppositeTracks(train.currentTrack())
        mode = (ot === nn.outTracks ? 1 : 2)
        var list = _k_.list(ot)
        for (var _184_22_ = 0; _184_22_ < list.length; _184_22_++)
        {
            nextTrack = list[_184_22_]
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
            nnopptrck = ((_192_59_=nextNode.oppositeTracks(nextTrack)) != null ? _192_59_ : [])
            if (nnopptrck.length)
            {
                train.path.addTrackNode(nextTrack,nextNode)
                return nextTrack
            }
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
        var car, maxAdvance, minCar, resource, _228_52_, _237_41_, _246_48_

        maxAdvance = advance
        minCar = null
        var list = _k_.list(train.boxcars())
        for (var _223_16_ = 0; _223_16_ < list.length; _223_16_++)
        {
            car = list[_223_16_]
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