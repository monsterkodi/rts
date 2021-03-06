###
00     00   0000000   000   000   0000000  000000000  00000000  00000000 
000   000  000   000  0000  000  000          000     000       000   000
000000000  000   000  000 0 000  0000000      000     0000000   0000000  
000 0 000  000   000  000  0000       000     000     000       000   000
000   000   0000000   000   000  0000000      000     00000000  000   000
###

{ fade } = require 'kxk'

class Monster

    constructor: (pos, dir) ->
        
        @bxs       = []
        @axes      = []
        @trail     = []
        @health    = config.monster.health
        @speed     = config.monster.speed
        @maxDist   = 4
        @trailSize = 0.04
        @length    = 16
        @radius    = 0.4
        @moved     = 0
        @dist      = 1/@length
        @pos       = pos ? vec()
        @nxt       = vec dir ? Vector.unitX
        @start     = vec @pos
        @stone     = randInt 4
        
        @vec = vec()
        @rot = quat()
        
        for i in [0...@length]
            size = (1-(i/@length))*@radius
            box  = boxes.add stone:Stone.monster, size:size
            @bxs.push box
            @axes.push vec @nxt
            boxes.setPos box, @pos.minus @nxt.mul i * @dist
            
        for i in [0...world.monsters.length%@length]
            @animate 0.5/@length
            
        @age = 0
        @ageTime = 20
            
    # 0000000    00000000  000      
    # 000   000  000       000      
    # 000   000  0000000   000      
    # 000   000  000       000      
    # 0000000    00000000  0000000  
    
    del: -> 
        
        return if @bxs.length <= 0
        
        for box in @bxs
            boxes.del box
        @bxs = []
        
        for box in @trail
            boxes.del box
        @trail = []
        
        index = world.monsters.indexOf @
        if index >= 0
            world.monsters.splice index, 1
            
    # 0000000     0000000   00     00   0000000    0000000   00000000  
    # 000   000  000   000  000   000  000   000  000        000       
    # 000   000  000000000  000000000  000000000  000  0000  0000000   
    # 000   000  000   000  000 0 000  000   000  000   000  000       
    # 0000000    000   000  000   000  000   000   0000000   00000000  
    
    damage: (amount) ->
        
        if empty @trail
            return
        box = @trail.shift()
        boxes.del box
        if empty @trail
            @die()
        else
            boxes.setStone @bxs[0], @stone
        
    # 0000000    000  00000000  
    # 000   000  000  000       
    # 000   000  000  0000000   
    # 000   000  000  000       
    # 0000000    000  00000000  
    
    die: ->
        
        for box in @bxs
            box.death =
                pos:  boxes.pos  box
                size: boxes.size box
                rot:  boxes.rot  box
                
        @dyingTime = 3
            
    isInDist: (pos) -> @start.manhattan(pos) <= @maxDist
            
    # 000000000  00000000    0000000   000  000      
    #    000     000   000  000   000  000  000      
    #    000     0000000    000000000  000  000      
    #    000     000   000  000   000  000  000      
    #    000     000   000  000   000  000  0000000  
    
    addTrail: (pos) ->
        
        if @trail.length < @health
            box = boxes.add stone:Stone.monster
            @trail.push box
        else
            box = @trail.shift()
            @trail.push box
        boxes.setPos box, pos
        boxes.setSize box, Math.min @trailSize, @trail.length/10 * @trailSize * Math.min 1, @age/@ageTime
            
    #  0000000   000   000  000  00     00   0000000   000000000  00000000  
    # 000   000  0000  000  000  000   000  000   000     000     000       
    # 000000000  000 0 000  000  000000000  000000000     000     0000000   
    # 000   000  000  0000  000  000 0 000  000   000     000     000       
    # 000   000  000   000  000  000   000  000   000     000     00000000  
    
    animateDying: (scaledDelta) ->
        
        @dyingTime -= scaledDelta
        
        if @dyingTime <= 0
            
            world.addStone @pos.x, @pos.y, @pos.z, Stone.monster
            world.addResource @pos.x, @pos.y, @pos.z, @stone, config.monster.resource
            world.construct.stones()
            @del()
            return
            
        f = 1-@dyingTime/3
        for box in @bxs
            boxes.setPos  box, box.death.pos.faded @pos, f
            boxes.setSize box, fade box.death.size, 1.1, f
            boxes.setRot  box, box.death.rot.slerp quat(), f
    
    animate: (scaledDelta) ->
        
        return if @bxs.length <= 0
                
        if @dyingTime
            @animateDying scaledDelta
            return
        
        lastInc = Math.floor @moved * @length
        
        @age   += scaledDelta
        @moved += scaledDelta * @speed
        
        nextInc = Math.floor @moved * @length
                
        if nextInc > lastInc
            for i in [lastInc...nextInc]
                @bxs.unshift @bxs.pop()
                @axes.unshift @axes.pop()
                box = @bxs[0]
                @addTrail boxes.pos @bxs[@bxs.length-3], @vec
                @vec.copy @nxt
                @vec.scale (i+1) * @dist
                @vec.add @pos
                boxes.setPos box, @vec
                boxes.setStone box, Stone.monster
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
            box = @bxs[i]
            boxes.setSize box, size
            boxes.setRot  box, Quaternion.axisAngle @axes[i], 360 * asgn
                
        if @trail.length >= @health
            for i in [0...Math.min(@trail.length, 10)]
                boxes.setSize @trail[i], (((i+1)-d)/10) * @trailSize
            
        if @moved > 1 
            @moved -= 1
            @findNextDirection()
                    
    # 000   000  00000000  000   000  000000000  
    # 0000  000  000        000 000      000     
    # 000 0 000  0000000     00000       000     
    # 000  0000  000        000 000      000     
    # 000   000  00000000  000   000     000     
    
    findNextDirection: ->
        
        @pos.add @nxt
        @vec.copy @nxt
        @vec.negate()
        handle.monsterMoved @
        choices = _.shuffle Vector.normals.filter (v) => not v.equals @vec
        for choice in choices
            @vec.copy @pos
            @vec.add choice
            if @isInDist @vec
                if world.noItemAtPos(@vec) and world.noStoneAroundPosInDirection(@vec, @nxt)                   
                    @nxt.copy choice
                    return
        @nxt.negate()

module.exports = Monster
