###
 0000000    0000000  000000000   0000000   00000000 
000   000  000          000     000   000  000   000
000000000  0000000      000     000000000  0000000  
000   000       000     000     000   000  000   000
000   000  0000000      000     000   000  000   000
###

{ valid, log, _ } = require 'kxk'

Vector = require './lib/vector'

class AStar

    constructor: (@world) ->
        
        @cameFrom = new Map

    dist: (start, goal) ->
        
        s = @world.posAtIndex start
        g = @world.posAtIndex goal
        1 + s.manhattan g 
        
    neighborCost: (start, neighbor) -> 1
        
    neighborsOfFaceIndex: (faceIndex) -> 
        
        faceDirections = [
            [Vector.PY, Vector.PZ, Vector.NY, Vector.NZ]
            [Vector.PZ, Vector.PX, Vector.NZ, Vector.NX]
            [Vector.PX, Vector.PY, Vector.NX, Vector.NY]
        ]

        [face, index] = @world.splitFaceIndex faceIndex
        pos = @world.posAtIndex index
        
        neighbors = []

        if @world.stoneAtPos(pos)?
            log 'stone above face!'
            return neighbors
        
        if not @world.stoneAtPos(pos.minus Vector.normals[face])?
            log 'no stone below face!'
            return neighbors
            
        for dir in faceDirections[face%3]

            unit = Vector.normals[dir]
            fpos = pos.plus unit
            dpos = fpos.minus Vector.normals[face]
            if @world.stoneAtPos(fpos)?
                neighbors.push @world.faceIndex (dir+3)%6, index
            else if @world.stoneAtPos(dpos)?
                neighbors.push @world.faceIndex face, @world.indexAtPos fpos
            else
                neighbors.push @world.faceIndex dir, @world.indexAtPos dpos
        
        neighbors
                
    lowestScore: (openSet, fScore) ->
        
        keys = Array.from openSet.keys()
        keys.sort (a,b) -> (fScore.get(a) ? Number.MAX_VALUE) - (fScore.get(b) ? Number.MAX_VALUE)
        keys[0]
        
    findPath: (start, goal) ->
        
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
    
        # For the first node, that value is completely heuristic.
        fScore.set start, @dist start, goal
    
        while valid openSet
            
            current = @lowestScore openSet, fScore # the node in openSet having the lowest fScore[] value
            if current == goal
                return @collectPath current
    
            openSet.delete current
            closedSet.set current, current
    
            for neighbor in @neighborsOfFaceIndex current
                
                if closedSet.get(neighbor) != undefined
                    continue # ignore the neighbor which is already evaluated.
    
                # distance from start to a neighbor
                tScore = (gScore.get(current) ? Number.MAX_VALUE) + @neighborCost current, neighbor
    
                if not openSet.get(neighbor)? # discover a new node
                    openSet.set neighbor, neighbor
                else if tScore >= (gScore.get(neighbor) ? Number.MAX_VALUE)
                    continue
    
                # path is the best until now
                @cameFrom.set neighbor, current
                gScore.set neighbor, tScore
                fScore.set neighbor, gScore.get(neighbor)+@dist(neighbor, goal)
                
    collectPath: (current) ->
        
        path = [current]
        while @cameFrom.get(current)?
            current = @cameFrom.get(current)
            path.push current
        return path
        
module.exports = AStar
