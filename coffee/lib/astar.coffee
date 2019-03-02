###
 0000000    0000000  000000000   0000000   00000000 
000   000  000          000     000   000  000   000
000000000  0000000      000     000000000  0000000  
000   000       000     000     000   000  000   000
000   000  0000000      000     000   000  000   000
###

{ valid, log, _ } = require 'kxk'

Vector = require './vector'

class AStar

    constructor: (@world) ->
        
    dist: (start, goal) ->
        
        s = @world.posAtIndex start
        g = @world.posAtIndex goal
        d = s.manhattan g
        if d == 1
            d += 1 if @world.splitFaceIndex(start)[0] != @world.splitFaceIndex(goal)[0]
        d
        
    neighborCost: (start, neighbor) -> 1
                
    getScore: (score, faceIndex) -> score.get(faceIndex) ? Number.MAX_VALUE
                
    lowestScore: (openSet, fScore) ->
        
        keys = Array.from openSet.keys()
        keys.sort (a,b) => @getScore(fScore, a) - @getScore(fScore, b)
        keys[0]
        
    findPath: (start, goal) -> @findWithNeighborFunc start, goal, @world.neighborsOfFaceIndex
    posPath: (fromPos, toPos) -> 
    
        start = @world.indexAtPos fromPos
        goal  = @world.indexAtPos toPos
        # log "posPath #{@world.stringForIndex start} posPath"
        @findWithNeighborFunc start, goal, @world.emptyNeighborsOfIndex
        
    findWithNeighborFunc: (start, goal, neighborFunc) ->
        
        closedSet = new Map # set of nodes already evaluated
    
        openSet = new Map # set of currently discovered nodes that are not evaluated yet
        openSet.set start, start
    
        # For each node, which node it can most efficiently be reached from.
        # If a node can be reached from many nodes, cameFrom will eventually contain the
        # most efficient previous step.
        @cameFrom = new Map
    
        # For each node, the cost of getting from the start node to that node.
        gScore = new Map # map with default value of Infinity
    
        # The cost of going from start to start is zero.
        gScore.set start, 0
    
        # For each node, the total cost of getting from the start node to the goal
        # by passing by that node. That value is partly known, partly heuristic.
        fScore = new Map # map with default value of Infinity
    
        # For the first node, that value is completely heuristic
        fScore.set start, @dist start, goal
    
        steps = 0
        
        while valid openSet
            
            steps += 1
            if steps > 2000
                log "dafuk? too many steps. bailing out. openSet:#{openSet.size} closedSet:#{closedSet.size} cameFrom:#{@cameFrom.size}"
                log "start: #{@world.stringForFaceIndex start} goal:#{@world.stringForFaceIndex goal}"
                # for open in Array.from openSet.keys()
                    # log open, @world.stringForFaceIndex open
                @world.drawBrokenPath
                    start:    start
                    goal:     goal
                    open:     Array.from openSet.keys()
                    closed:   Array.from closedSet.keys()
                    cameFrom: Array.from @cameFrom.keys()
                rts.togglePause()
                return #@collectPath current
                
            current = @lowestScore openSet, fScore # the node in openSet having the lowest fScore value
            if current == goal
                return @collectPath current
    
            openSet.delete current
            closedSet.set current, current
    
            for neighbor in neighborFunc current
                
                if closedSet.get(neighbor) != undefined
                    continue # ignore the neighbor which is already evaluated.
    
                # distance from start to a neighbor
                tScore = @getScore(gScore, current) + @neighborCost current, neighbor
    
                if not openSet.get(neighbor)? # discover a new node
                    openSet.set neighbor, neighbor
                else if tScore >= @getScore gScore, neighbor
                    continue
    
                # path is the best until now
                @cameFrom.set neighbor, current
                gScore.set neighbor, tScore
                fScore.set neighbor, @getScore(gScore, neighbor)+@dist(neighbor, goal)
                
    collectPath: (current) ->
        
        path = [current]
        while @cameFrom.get(current)?
            current = @cameFrom.get(current)
            # path.push current
            path.unshift current
        return path
        
module.exports = AStar
