// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}}

class AStar
{
    constructor ()
    {
        this.startPos = vec()
        this.goalPos = vec()
    }

    dist (start, goal)
    {
        var d

        if (start === goal)
        {
            return 0
        }
        world.indexToPos(start,this.startPos)
        world.indexToPos(goal,this.goalPos)
        d = this.startPos.manhattan(this.goalPos)
        if (d === 0 || d === 1 && world.splitFaceIndex(start)[0] !== world.splitFaceIndex(goal)[0])
        {
            d += 1
        }
        return d
    }

    neighborCost (start, neighbor)
    {
        return 1
    }

    getScore (score, faceIndex)
    {
        var _30_57_

        return ((_30_57_=score.get(faceIndex)) != null ? _30_57_ : Number.MAX_VALUE)
    }

    lowestScore (openSet, fScore)
    {
        var keys

        keys = Array.from(openSet.keys())
        keys.sort((function (a, b)
        {
            return this.getScore(fScore,a) - this.getScore(fScore,b)
        }).bind(this))
        return keys[0]
    }

    findPath (start, goal)
    {
        return this.findWithNeighborFunc(start,goal,world.neighborsOfFaceIndex)
    }

    posPath (fromPos, toPos)
    {
        var goal, start

        start = world.indexAtPos(fromPos)
        goal = world.indexAtPos(toPos)
        return this.findWithNeighborFunc(start,goal,world.emptyNeighborsOfIndex)
    }

    bulletPath (fromBot, toBot)
    {
        var filterFunc, goal, start

        start = world.indexAtBot(fromBot)
        goal = world.indexAtBot(toBot)
        filterFunc = function (world, acceptBot)
        {
            return function (index)
            {
                return world.emptyOrBotNeighborsOfIndex(index).filter(function (ni)
                {
                    return world.botAtIndex(ni) === acceptBot || world.noBotAtIndex(ni)
                })
            }
        }
        return this.findWithNeighborFunc(start,goal,filterFunc(world,toBot))
    }

    findWithNeighborFunc (start, goal, neighborFunc)
    {
        var cameFrom, closedSet, current, fScore, gScore, neighbor, openSet, steps, tScore, _118_44_

        closedSet = new Map
        openSet = new Map
        openSet.set(start,start)
        cameFrom = new Map
        gScore = new Map
        gScore.set(start,0)
        fScore = new Map
        fScore.set(start,this.dist(start,goal))
        steps = 0
        while (openSet.size > 0)
        {
            steps += 1
            if (steps > 2000)
            {
                console.log(`AStar -- too many steps. bailing out. openSet:${openSet.size} closedSet:${closedSet.size} cameFrom:${cameFrom.size}`)
                return
            }
            current = this.lowestScore(openSet,fScore)
            if (current === goal)
            {
                return this.collectPath(current,cameFrom)
            }
            openSet.delete(current)
            closedSet.set(current,current)
            var list = _k_.list(neighborFunc(current))
            for (var _110_25_ = 0; _110_25_ < list.length; _110_25_++)
            {
                neighbor = list[_110_25_]
                if (closedSet.get(neighbor) !== undefined)
                {
                    continue
                }
                tScore = this.getScore(gScore,current) + this.neighborCost(current,neighbor)
                if (!(openSet.get(neighbor) != null))
                {
                    openSet.set(neighbor,neighbor)
                }
                else if (tScore >= this.getScore(gScore,neighbor))
                {
                    continue
                }
                cameFrom.set(neighbor,current)
                gScore.set(neighbor,tScore)
                fScore.set(neighbor,this.getScore(gScore,neighbor) + this.dist(neighbor,goal))
            }
        }
    }

    collectPath (current, cameFrom)
    {
        var path, _131_35_

        path = [current]
        while ((cameFrom.get(current) != null))
        {
            current = cameFrom.get(current)
            path.unshift(current)
        }
        return path
    }
}

module.exports = AStar