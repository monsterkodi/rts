###
00000000   00000000   0000000   0000000   000   000  00000000    0000000  00000000
000   000  000       000       000   000  000   000  000   000  000       000     
0000000    0000000   0000000   000   000  000   000  0000000    000       0000000 
000   000  000            000  000   000  000   000  000   000  000       000     
000   000  00000000  0000000    0000000    0000000   000   000   0000000  00000000
###

class Resource

    constructor: (@world, @index, @stone, @amount) ->
        
        @boxes = []
        for i in [0...6]
            @boxes.push @world.resourceBoxes.add stone:@stone
        
        @deduct 0
            
    sizeForAmount: (amount) ->
        
        clamp 0.0, 0.5, 0.5 * Math.sqrt((amount-1)/512)
        
    deduct: (amount=1) ->

        @amount -= amount
        if @amount <= 0
            @del()
            return
            
        pos = @world.posAtIndex @index
        size = @sizeForAmount @amount
        r = 0.6 - size/2
        for i in [0...6]            
            box = @boxes[i]
            @world.resourceBoxes.setSize box, size
            @world.resourceBoxes.setPos  box, pos.plus Vector.normals[i].mul r
            
    del: ->
        
        for box in @boxes
            @world.resourceBoxes.del box
        @boxes = []
        delete @world.resources[@index]
        for neighbor in @world.neighborsOfIndex @index
            if bot = @world.bots[neighbor]
                @world.construct.updateBot bot

module.exports = Resource
