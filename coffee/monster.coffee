###
00     00   0000000   000   000   0000000  000000000  00000000  00000000 
000   000  000   000  0000  000  000          000     000       000   000
000000000  000   000  000 0 000  0000000      000     0000000   0000000  
000 0 000  000   000  000  0000       000     000     000       000   000
000   000   0000000   000   000  0000000      000     00000000  000   000
###

{ last, deg2rad, randInt, log, _ } = require 'kxk'

{ Stone } = require './constants'

Vector = require './lib/vector'

class Monster

    constructor: (world, pos, dir) ->
        
        @boxes     = []
        @axes      = []
        @trail     = []
        @speed     = 0.4
        @maxDist   = 4
        @maxTrail  = 200
        @trailSize = 0.05
        @length    = 16
        @radius    = 0.4
        @moved     = 0
        @dist      = 1/@length
        @pos       = pos ? vec()
        @nxt       = vec dir ? Vector.unitX
        @start     = vec @pos
        
        for i in [0...@length]
            size = (1-(i/@length))*@radius
            box  = world.boxes.add stone:Stone.monster, size:size
            @boxes.push box
            @axes.push vec @nxt
            rts.world.boxes.setPos box, @pos.minus @nxt.mul i * @dist
        
    isInDist: (pos) -> @start.manhattan(pos) <= @maxDist
            
    addTrail: (pos) ->
        
        if @trail.length < @maxTrail
            box = rts.world.boxes.add stone:Stone.monster
            @trail.push box
        else
            box = @trail.shift()
            @trail.push box
        rts.world.boxes.setPos box, pos
        rts.world.boxes.setSize box, Math.min @trailSize, @trail.length/10 * @trailSize
            
    animate: (scaledDelta) ->

        lastInc = Math.floor @moved * @length
        
        @moved += scaledDelta * @speed
        
        nextInc = Math.floor @moved * @length
        
        if nextInc > lastInc
            for i in [lastInc...nextInc]
                @boxes.unshift @boxes.pop()
                @axes.unshift @axes.pop()
                box = @boxes[0]
                @addTrail rts.world.boxes.pos @boxes[@boxes.length-3]
                newPos = @pos.plus @nxt.mul (i+1) * @dist
                rts.world.boxes.setPos box, newPos
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
            rts.world.boxes.setSize box, size
            rts.world.boxes.setRot  box, quat().setFromAxisAngle @axes[i], deg2rad 360 * asgn
                
        if @trail.length >= @maxTrail
            for i in [0...10]
                rts.world.boxes.setSize @trail[i], (((i+1)-d)/10) * @trailSize
            
        if @moved > 1
            @pos.add @nxt
            choices = _.shuffle Vector.normals.filter (v) => not v.equals @nxt.neg()
            @moved -= 1
            for choice in choices
                if not rts.world.isItemAtPos @pos.plus choice
                    if @isInDist @pos.plus choice
                        @nxt = vec choice
                        return
            @nxt.negate()

module.exports = Monster
