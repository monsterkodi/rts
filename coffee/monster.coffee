###
00     00   0000000   000   000   0000000  000000000  00000000  00000000 
000   000  000   000  0000  000  000          000     000       000   000
000000000  000   000  000 0 000  0000000      000     0000000   0000000  
000 0 000  000   000  000  0000       000     000     000       000   000
000   000   0000000   000   000  0000000      000     00000000  000   000
###

{ fade, last, empty, deg2rad, randInt, log, _ } = require 'kxk'

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
        @stone     = [Stone.red,Stone.red,Stone.red, Stone.white,Stone.white, Stone.gelb, Stone.blue][randInt 7]
        
        for i in [0...@length]
            size = (1-(i/@length))*@radius
            box  = @world.boxes.add stone:Stone.monster, size:size
            @boxes.push box
            @axes.push vec @nxt
            @world.boxes.setPos box, @pos.minus @nxt.mul i * @dist
            
        for i in [0...@world.monsters.length%@length]
            @animate 0.5/@length
            
        @age = 0
        @ageTime = 20
            
    del: -> 
        
        return if empty @boxes
        
        for box in @boxes
            @world.boxes.del box
        @boxes = []
        
        index = @world.monsters.indexOf @
        if index >= 0
            @world.monsters.splice index, 1
            @world.addStone @pos.x, @pos.y, @pos.z, Stone.monster
            @world.addResource @pos.x, @pos.y, @pos.z, @stone, state.monster.resource
            @world.construct.stones()
        else
            log 'dafuk?'
            
    damage: (amount) ->
        
        if empty @trail
            return
        box = @trail.shift()
        @world.boxes.del box
        if empty @trail
            @die()
        else
            @world.boxes.setStone @boxes[0], @stone
        
    die: ->
        
        for box in @boxes
            box.death =
                pos:  @world.boxes.pos  box
                size: @world.boxes.size box
                rot:  @world.boxes.rot  box
                
        @dyingTime = 3
            
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
        @world.boxes.setSize box, Math.min @trailSize, @trail.length/10 * @trailSize * Math.min 1, @age/@ageTime
            
    #  0000000   000   000  000  00     00   0000000   000000000  00000000  
    # 000   000  0000  000  000  000   000  000   000     000     000       
    # 000000000  000 0 000  000  000000000  000000000     000     0000000   
    # 000   000  000  0000  000  000 0 000  000   000     000     000       
    # 000   000  000   000  000  000   000  000   000     000     00000000  
    
    animateDying: (scaledDelta) ->
        
        @dyingTime -= scaledDelta
        
        if @dyingTime <= 0
            @del()
            return
            
        for box in @boxes
            @world.boxes.setPos  box, box.death.pos.faded @pos, 1-@dyingTime/3
            @world.boxes.setSize box, fade box.death.size, 1.1, 1-@dyingTime/3
            @world.boxes.setRot  box, box.death.rot.slerp quat(), 1-@dyingTime/3
    
    animate: (scaledDelta) ->

        return if empty @boxes
        
        if @dyingTime
            @animateDying scaledDelta
            return
        
        lastInc = Math.floor @moved * @length
        
        @age   += scaledDelta
        @moved += scaledDelta * @speed
        
        nextInc = Math.floor @moved * @length
        
        if nextInc > lastInc
            newPos = vec()
            for i in [lastInc...nextInc]
                @boxes.unshift @boxes.pop()
                @axes.unshift @axes.pop()
                box = @boxes[0]
                @addTrail @world.boxes.pos @boxes[@boxes.length-3]
                newPos.copy @nxt
                newPos.scale (i+1) * @dist
                newPos.add @pos
                @world.boxes.setPos box, newPos
                @world.boxes.setStone box, Stone.monster
                @axes[0].copy @nxt

        d = @moved * @length - nextInc
        
        for i in [0...@length]
            if i < @length/2
                fact = (i+d)/@length
                asgn = fact
            else
                fact = 1-((i+d)/@length)
                asgn = -fact
                
            size = fact*@radius * Math.min 1, @age/@ageTime
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
                choicePos = @pos.plus choice
                if not @world.isItemAtPos choicePos
                    if @isInDist choicePos
                        @nxt.copy choice
                        return
            @nxt.negate()

module.exports = Monster
