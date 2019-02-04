###
 0000000    0000000  000000000   0000000   00000000 
000   000  000          000     000   000  000   000
000000000  0000000      000     000000000  0000000  
000   000       000     000     000   000  000   000
000   000  0000000      000     000   000  000   000
###

{ valid, log, _ } = require 'kxk'

class AStar

    constructor: (@world) ->
        
        @cameFrom = {}

    collectPath: (current) ->
        
        path = [current]
        while @cameFrom[current]?
            current = @cameFrom[current]
            path.append current
            
        return path

    dist: (start, goal) ->
        
        @world.posAtIndex(start).dist @world.posAtIndex goal
        
    neighborCost: (start, neighbor) -> 1
        
    neighborsOfFaceIndex: (index) -> 
        p = @world.posAtIndex index
        [
            @world.indexAtPos p.x+1, p.y, p.z
            @world.indexAtPos p.x, p.y+1, p.z
            @world.indexAtPos p.x, p.y, p.z+1
            @world.indexAtPos p.x-1, p.y, p.z
            @world.indexAtPos p.x, p.y-1, p.z
            @world.indexAtPos p.x, p.y, p.z-1
        ]
        
    lowestScore: (openSet, fScore) ->
        
        keys = Object.keys openSet
        keys.sort (a,b) -> (fScore[a] ? Number.MAX_VALUE) - (fScore[b] ? Number.MAX_VALUE)
        keys[0]
        
    findPath: (start, goal) ->
        
        closedSet = {} # set of nodes already evaluated
    
        openSet = {} # set of currently discovered nodes that are not evaluated yet
        openSet[start] = start
    
        # For each node, which node it can most efficiently be reached from.
        # If a node can be reached from many nodes, cameFrom will eventually contain the
        # most efficient previous step.
        @cameFrom = {}
    
        # For each node, the cost of getting from the start node to that node.
        gScore = {} # map with default value of Infinity
    
        # The cost of going from start to start is zero.
        gScore[start] = 0
    
        # For each node, the total cost of getting from the start node to the goal
        # by passing by that node. That value is partly known, partly heuristic.
        fScore = {} # map with default value of Infinity
    
        # For the first node, that value is completely heuristic.
        fScore[start] = @dist start, goal
    
        while valid openSet
            
            current = @lowestScore openSet, fScore # the node in openSet having the lowest fScore[] value
            
            if current == goal
                return @collectPath current
    
            delete openSet[current]
            closedSet[current] = current
    
            for neighbor in @neighborsOfFaceIndex current
                if closedSet[neighbor]?
                    continue # ignore the neighbor which is already evaluated.
    
                # distance from start to a neighbor
                tScore = (gScore[current] ? Number.MAX_VALUE) + @neighborCost current, neighbor
    
                if not openSet[neighbor]? # discover a new node
                    openSet[neighbor] = neighbor
                else if tScore >= (gScore[neighbor] ? Number.MAX_VALUE)
                    continue
    
                # path is the best until now
                @cameFrom[neighbor] = current
                gScore[neighbor] = tScore

module.exports = AStar
