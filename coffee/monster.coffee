###
00     00   0000000   000   000   0000000  000000000  00000000  00000000 
000   000  000   000  0000  000  000          000     000       000   000
000000000  000   000  000 0 000  0000000      000     0000000   0000000  
000 0 000  000   000  000  0000       000     000     000       000   000
000   000   0000000   000   000  0000000      000     00000000  000   000
###

{ deg2rad, randInt, log, _ } = require 'kxk'

{ Stone } = require './constants'

Vector = require './lib/vector'

class Monster

    constructor: (world, pos, dir) ->
        
        @boxes  = []
        @axes   = []
        @length = 10
        @radius = 0.4
        @moved  = 0
        @dist   = 1/@length
        
        @nxt = vec dir ? Vector.unitX
        @pos = pos ? vec()
        
        for i in [0...@length]
            size = (1-(i/@length))*@radius
            box  = world.boxes.add stone:Stone.monster, size:size
            @boxes.push box
            @axes.push vec @nxt
            rts.world.boxes.setPos box, @pos.minus @nxt.mul i * @dist
        
    animate: (scaledDelta) ->

        lastInc = Math.floor @moved * @length
        
        @moved += scaledDelta * 0.1
        
        nextInc = Math.floor @moved * @length
        
        if nextInc > lastInc
            for i in [lastInc...nextInc]
                @boxes.unshift @boxes.pop()
                @axes.unshift @axes.pop()
                box = @boxes[0]
                rts.world.boxes.setPos box, @pos.plus @nxt.mul (i+1) * @dist
                @axes[0] = vec @nxt

        d = @moved * @length - nextInc
        size = ((1-@dist)*d)*@radius
        rts.world.boxes.setSize @boxes[0], size
        rts.world.boxes.setRot  @boxes[0], quat().setFromAxisAngle @axes[0], deg2rad 180 * (1-((0+d)/@length))
        
        for i in [1...@length]
            size = (1-((i+d)/@length))*@radius
            box = @boxes[i]
            rts.world.boxes.setSize box, size
            rts.world.boxes.setRot  box, quat().setFromAxisAngle @axes[i], deg2rad 180 * (1-((i+d)/@length))
                
        if @moved > 1
            @pos.add @nxt
            @nxt = vec Vector.normals[randInt 6]
            @moved -= 1

module.exports = Monster
