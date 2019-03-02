###
 0000000   0000000   000   000   0000000  00000000  00000000 
000       000   000  0000  000  000       000       000   000
000       000000000  000 0 000  000       0000000   0000000  
000       000   000  000  0000  000       000       000   000
 0000000  000   000  000   000   0000000  00000000  000   000
###

{ valid, randInt, deg2rad, log, _ } = require 'kxk'

{ Stone } = require './constants'

Vector    = require './lib/vector'
Materials = require './materials'

class Cancer

    @cells: {}

    @isCellAtIndex: (i) -> @cells[i]?
    
    constructor: (@world, @pos, @maxDist=10) ->
        
        @boxes     = []
        @growBoxes = {}
        @growCells = []
        @growTime  = Math.random() * state.cancer.growTime
        @ageTime   = state.cancer.ageTime
        @cellsSinceLastMonster = 0
        @spawnAtPos @pos
                    
    grow: ->
        
        growCell = @growCells[randInt @growCells.length]
        neighbors = @world.neighborsOfIndex growCell
        neighbors = neighbors.filter (n) => 
            return false if Cancer.cells[n] 
            return false if @world.isItemAtIndex n 
            npos = @world.posAtIndex n
            cpos = @world.posAtIndex growCell
            return @world.noStoneAroundPosInDirection npos, cpos.to npos
        
        if valid neighbors
            neighbor = neighbors[randInt neighbors.length]
            pos = @world.posAtIndex neighbor
            if pos.dist(@pos) <= @maxDist
                @spawnAtPos pos
            if neighbors.length <= 5 or pos.dist(@pos) > @maxDist
                @growCells.splice @growCells.indexOf(growCell), 1
                            
    spawnAtPos: (pos) ->
        
        @cellsSinceLastMonster += 1
        if @cellsSinceLastMonster >= state.cancer.cellsPerMonster
            @cellsSinceLastMonster = 0
            @world.addMonster pos.x, pos.y, pos.z
        
        numGrow = 4
        index = @world.indexAtPos pos
        Cancer.cells[index] = index
        @growCells.push index
        @growBoxes[index] = []
        
        for i in [0...numGrow]
            box  = @world.boxes.add stone:Stone.cancer, size:0.001, pos:pos
            box.axis = Vector.random()
            box.age = 0
            
            @world.boxes.setRot box, quat().setFromUnitVectors vec(0,0,1), box.axis
            
            @boxes.push box
            @growBoxes[index].push box

    animate: (scaledDelta) ->
        
        @growTime -= scaledDelta
        if @growTime <= 0
            @growTime = state.cancer.growTime - @growTime
            @grow()
            
        for index,boxes of @growBoxes
            for box in boxes
                rot = @world.boxes.rot box
                box.age += scaledDelta
                @world.boxes.setSize box, Math.min 1, box.age / @ageTime
                @world.boxes.setRot  box, rot.multiply quat().setFromAxisAngle box.axis, deg2rad state.cancer.rotSpeed*scaledDelta
                if box.age >= @ageTime
                    delete @growBoxes[index]
            
module.exports = Cancer
