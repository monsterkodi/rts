###
00000000   00000000   0000000   0000000   000   000  00000000    0000000  00000000
000   000  000       000       000   000  000   000  000   000  000       000     
0000000    0000000   0000000   000   000  000   000  0000000    000       0000000 
000   000  000            000  000   000  000   000  000   000  000       000     
000   000  00000000  0000000    0000000    0000000   000   000   0000000  00000000
###

{ clamp, log, _ } = require 'kxk'

{ Stone } = require './constants'

Vector = require './lib/vector'

class Resource

    constructor: (@world, @index, @stone, @amount) ->
        
        log 'resource', @index, Stone.string(@stone), @amount

        @boxes = []
        for i in [0...6]
            @boxes.push @world.boxes.add stone:@stone
        
        @deduct 0
            
    sizeForAmount: (amount) ->
        
        clamp 0.05, 0.5, 0.5 * Math.sqrt(amount/512)
        
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
            @world.boxes.setSize box, size
            @world.boxes.setPos  box, pos.plus Vector.normals[i].mul r
            
    del: ->
        
        for box in @boxes
            @world.boxes.del box
        @boxes = []
        delete @world.resources[@index]
        for neighbor in @world.neighborsOfIndex @index
            if bot = @world.bots[neighbor]
                @world.construct.updateBot bot

module.exports = Resource
