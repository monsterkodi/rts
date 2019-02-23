###
00     00   0000000   000   000   0000000  000000000  00000000  00000000 
000   000  000   000  0000  000  000          000     000       000   000
000000000  000   000  000 0 000  0000000      000     0000000   0000000  
000 0 000  000   000  000  0000       000     000     000       000   000
000   000   0000000   000   000  0000000      000     00000000  000   000
###

{ last, empty, deg2rad, randInt, log, _ } = require 'kxk'

{ Stone } = require './constants'

Vector = require './lib/vector'

class Monster

    constructor: (@world, pos, dir) ->
        
        @boxes     = []
        @axes      = []
        @trail     = []
        @health    = state.monster.health
        @speed     = state.monster.speed
        @maxDist   = 4
        @trailSize = 0.04
        @length    = 16
        @radius    = 0.4
        @moved     = 0
        @dist      = 1/@length
        @pos       = pos ? vec()
        @nxt       = vec dir ? Vector.unitX
        @start     = vec @pos
        
        for i in [0...@length]
            size = (1-(i/@length))*@radius
            box  = @world.boxes.add stone:Stone.monster, size:size
            @boxes.push box
            @axes.push vec @nxt
            @world.boxes.setPos box, @pos.minus @nxt.mul i * @dist
            
        for i in [0...@world.monsters.length%@length]
            @animate 0.5/@length
            
    del: -> 
        
        return if empty @boxes
        for box in @boxes
            @world.boxes.del box
        @boxes = []
        index = @world.monsters.indexOf @
        if index >= 0
            @world.monsters.splice index, 1
        
    damage: (amount) ->
        
        if empty @trail
            log 'empty?', @health, empty @boxes
            return
        box = @trail.shift()
        @world.boxes.del box
        if empty @trail
            @del()
        
    isInDist: (pos) -> @start.manhattan(pos) <= @maxDist
            
    # 000000000  00000000    0000000   000  000      
    #    000     000   000  000   000  000  000      
    #    000     0000000    000000000  000  000      
    #    000     000   000  000   000  000  000      
    #    000     000   000  000   000  000  0000000  
    
    addTrail: (pos) ->
        
        if @trail.length < @health
            box = @world.boxes.add stone:Stone.monster
            @trail.push box
        else
            box = @trail.shift()
            @trail.push box
        @world.boxes.setPos box, pos
        @world.boxes.setSize box, Math.min @trailSize, @trail.length/10 * @trailSize
            
    #  0000000   000   000  000  00     00   0000000   000000000  00000000  
    # 000   000  0000  000  000  000   000  000   000     000     000       
    # 000000000  000 0 000  000  000000000  000000000     000     0000000   
    # 000   000  000  0000  000  000 0 000  000   000     000     000       
    # 000   000  000   000  000  000   000  000   000     000     00000000  
    
    animate: (scaledDelta) ->

        return if empty @boxes
        
        lastInc = Math.floor @moved * @length
        
        @moved += scaledDelta * @speed
        
        nextInc = Math.floor @moved * @length
        
        if nextInc > lastInc
            for i in [lastInc...nextInc]
                @boxes.unshift @boxes.pop()
                @axes.unshift @axes.pop()
                box = @boxes[0]
                @addTrail @world.boxes.pos @boxes[@boxes.length-3]
                newPos = @pos.plus @nxt.mul (i+1) * @dist
                @world.boxes.setPos box, newPos
                @axes[0] = vec @nxt

        d = @moved * @length - nextInc
        
        for i in [0...@length]
            if i < @length/2
                fact = (i+d)/@length
                asgn = fact
            else
                fact = 1-((i+d)/@length)
                asgn = -fact
                
            size = fact*@radius
            box = @boxes[i]
            @world.boxes.setSize box, size
            @world.boxes.setRot  box, quat().setFromAxisAngle @axes[i], deg2rad 360 * asgn
                
        if @trail.length >= @health
            for i in [0...Math.min(@trail.length, 10)]
                @world.boxes.setSize @trail[i], (((i+1)-d)/10) * @trailSize
            
        if @moved > 1
            @moved -= 1
            @pos.add @nxt
            rts.handle.monsterMoved @
            choices = _.shuffle Vector.normals.filter (v) => not v.equals @nxt.neg()
            for choice in choices
                if not @world.isItemAtPos @pos.plus choice
                    if @isInDist @pos.plus choice
                        @nxt = vec choice
                        return
            @nxt.negate()

module.exports = Monster
