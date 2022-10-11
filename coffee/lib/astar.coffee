###
 0000000    0000000  000000000   0000000   00000000 
000   000  000          000     000   000  000   000
000000000  0000000      000     000000000  0000000  
000   000       000     000     000   000  000   000
000   000  0000000      000     000   000  000   000
###

class AStar

    constructor: ->
        
        @startPos = vec()
        @goalPos  = vec()
        
    dist: (start, goal) ->
        
        if start == goal
            return 0
            
        world.indexToPos start, @startPos
        world.indexToPos goal, @goalPos
        d = @startPos.manhattan @goalPos
        if d == 0 or d == 1 and world.splitFaceIndex(start)[0] != world.splitFaceIndex(goal)[0]
            d += 1
        d
        
    neighborCost: (start, neighbor) -> 1
                
    getScore: (score, faceIndex) -> score.get(faceIndex) ? Number.MAX_VALUE
                
    lowestScore: (openSet, fScore) ->
        
        keys = Array.from openSet.keys()
        keys.sort (a,b) => @getScore(fScore, a) - @getScore(fScore, b)
        keys[0]
        
    findPath: (start, goal) -> @findWithNeighborFunc start, goal, world.neighborsOfFaceIndex
    posPath: (fromPos, toPos) -> 
    
        start = world.indexAtPos fromPos
        goal  = world.indexAtPos toPos
        # log "posPath #{world.stringForIndex start} posPath"
        @findWithNeighborFunc start, goal, world.emptyNeighborsOfIndex
        
    bulletPath: (fromBot, toBot) ->

        start = world.indexAtBot fromBot
        goal  = world.indexAtBot toBot
        
        filterFunc = (world, acceptBot) -> (index) -> 
            world.emptyOrBotNeighborsOfIndex(index).filter (ni) -> 
                world.botAtIndex(ni) == acceptBot or world.noBotAtIndex(ni)
        
        @findWithNeighborFunc start, goal, filterFunc(world,toBot)
        
    findWithNeighborFunc: (start, goal, neighborFunc) ->
        
        # log "findWithNeighborFunc #{start} #{goal}"
        
        closedSet = new Map # set of nodes already evaluated
    
        openSet = new Map # set of currently discovered nodes that are not evaluated yet
        openSet.set start, start
    
        # For each node, which node it can most efficiently be reached from.
        # If a node can be reached from many nodes, cameFrom will eventually contain the
        # most efficient previous step.
        cameFrom = new Map
    
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
        
        while openSet.size > 0
            
            steps += 1
            if steps > 2000
                log "AStar -- too many steps. bailing out. openSet:#{openSet.size} closedSet:#{closedSet.size} cameFrom:#{cameFrom.size}"
                # log "start: #{world.stringForFaceIndex start} goal:#{world.stringForFaceIndex goal}"
                # for open in Array.from openSet.keys()
                    # log open, world.stringForFaceIndex open
                # world.drawBrokenPath
                    # start:    start
                    # goal:     goal
                    # open:     Array.from openSet.keys()
                    # closed:   Array.from closedSet.keys()
                    # cameFrom: Array.from @cameFrom.keys()
                # rts.togglePause()
                return #@collectPath current
                
            current = @lowestScore openSet, fScore # the node in openSet having the lowest fScore value
            if current == goal
                return @collectPath current, cameFrom
    
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
                cameFrom.set neighbor, current
                gScore.set neighbor, tScore
                fScore.set neighbor, @getScore(gScore, neighbor)+@dist(neighbor, goal)
                
    collectPath: (current, cameFrom) ->
        
        path = [current]
        while cameFrom.get(current)?
            current = cameFrom.get(current)
            path.unshift current
        path
        
module.exports = AStar
