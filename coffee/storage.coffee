###
 0000000  000000000   0000000   00000000    0000000    0000000   00000000
000          000     000   000  000   000  000   000  000        000     
0000000      000     000   000  0000000    000000000  000  0000  0000000 
     000     000     000   000  000   000  000   000  000   000  000     
0000000      000      0000000   000   000  000   000   0000000   00000000
###

{ post, clamp, menu, log, _ } = require 'kxk'

{ Stone } = require './constants'

class Storage 

    constructor: (@world, @player) ->
        
        @stones = [0,0,0,0]
        @temp   = [0,0,0,0]

        @resetBalance()
        
        # if @player == 0
        for stone in Stone.resources
            @add stone, state.storage.stones[stone], 'init'
        
        post.on 'scienceFinished', @onScienceFinished
                    
    onScienceFinished: (scienceKey) =>
        
        if scienceKey == 'storage.capacity'
            stones = _.clone @stones
            @deduct @stones, 'reset'
            for stone in Stone.resources
                @add stone, stones[stone], 'reset'
                        
    resetBalance: -> @balance = gains:[0,0,0,0], spent:[0,0,0,0]
        
    capacity: -> state.science.storage.capacity
                       
    has: (stone, amount) -> @stones[stone] >= amount
            
    canTake: (stone, amount=1) -> 
        
        return 0 if stone == Stone.gray
        clamp 0, amount, @capacity() - @stones[stone] - @temp[stone]

    willSend: (stone) -> @temp[stone] += 1
        
    deductBuild: -> 
        
        if @canAfford state.science.build.cost
            @deduct state.science.build.cost
            @dirty = true
            return true
        false
        
    canAfford: (cost) ->
        
        for stone in Stone.resources
            if @stones[stone] < cost[stone]
                return false
        true
                
    clear: -> @deduct @stones, 'clear'
    fill:  -> @deduct [-@capacity(), -@capacity(), -@capacity(), -@capacity()], 'fill'

    deduct: (cost, reason) ->
        
        for stone in Stone.resources
            @add stone, -cost[stone], reason
    
    add: (stone, amount=1, reason=null) ->
        
        oldStones = @stones[stone]
        
        @stones[stone] += amount
        @stones[stone] = clamp 0, @capacity(), @stones[stone]
        
        if not reason
            delta = @stones[stone]-oldStones
            if delta > 0
                @balance.gains[stone] += delta
            else 
                @balance.spent[stone] -= delta

        post.emit 'storageChanged', @, stone, @stones[stone]
                                        
module.exports = Storage
