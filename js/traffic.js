// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}, in: function (a,l) {return (typeof l === 'string' && typeof a === 'string' && a.length ? '' : []).indexOf.call(l,a) >= 0}}

var HEAD_DISTANCE, REAREND_DISTANCE, TAIL_DISTANCE, Traffic

HEAD_DISTANCE = 12
TAIL_DISTANCE = 8
REAREND_DISTANCE = 6

Traffic = (function ()
{
    function Traffic ()
    {
        this.trains = []
    }

    Traffic.prototype["addTrain"] = function (train)
    {
        return this.trains.push(train)
    }

    Traffic.prototype["simulate"] = function (scaledDelta, timeSum)
    {
        return this.nodeSignals()
    }

    Traffic.prototype["nodeSignals"] = function ()
    {
        var n, p, path, s, tailDelta, train

        var list = _k_.list(this.trains)
        for (var _27_18_ = 0; _27_18_ < list.length; _27_18_++)
        {
            train = list[_27_18_]
            path = train.path
            p = path.nextDistance()
            if (p < HEAD_DISTANCE)
            {
                n = path.nextNode()
                if (n.train !== train)
                {
                    if (!n.train)
                    {
                        n.setTrain(train)
                    }
                    else
                    {
                        if (!(_k_.in(train,n.blockedTrains)))
                        {
                            if (train.path.currentTrack() !== n.train.tailTrack() && train.path.currentTrack() !== n.train.prevTailTrack() && train.path.nextTrack() !== n.train.tailTrack())
                            {
                                n.block(train)
                            }
                            else
                            {
                                if (train.path.currentTrack() === n.train.prevTailTrack())
                                {
                                    n.setTrain(train)
                                }
                            }
                        }
                    }
                }
            }
            tailDelta = train.tailDelta()
            s = path.prevDistance(tailDelta)
            if (s > TAIL_DISTANCE)
            {
                n = path.prevNode(tailDelta)
                if (n.train === train)
                {
                    n.unblock()
                }
            }
        }
    }

    Traffic.prototype["allowTrainAdvance"] = function (train, advance)
    {
        var delta, other, track, trainToOther

        delta = train.path.delta + advance
        track = train.path.trackAtDelta(delta)
        var list = _k_.list(this.trains)
        for (var _56_18_ = 0; _56_18_ < list.length; _56_18_++)
        {
            other = list[_56_18_]
            if (other === train)
            {
                continue
            }
            if (other.tailTrack() === track)
            {
                trainToOther = other.tailPrevDistance() - train.path.prevDistance(delta)
                if (trainToOther >= 0 && trainToOther < REAREND_DISTANCE)
                {
                    return 0
                }
            }
            else if (other.prevTailTrack() === track)
            {
                trainToOther = other.tailPrevDistance() + train.path.nextDistance(delta)
                if (trainToOther >= 0 && trainToOther < REAREND_DISTANCE)
                {
                    return 0
                }
            }
        }
        return advance
    }

    return Traffic
})()

module.exports = Traffic