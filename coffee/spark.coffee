###
 0000000  00000000    0000000   00000000   000   000
000       000   000  000   000  000   000  000  000 
0000000   00000000   000000000  0000000    0000000  
     000  000        000   000  000   000  000  000 
0000000   000        000   000  000   000  000   000
###

{ empty, log, _ } = require 'kxk'

{ Stone } = require './constants'

Materials = require './materials'

class Spark

    @spawn: (world, base, monster) ->
        
        storage = world.storage[base.player]
        
        func = -> 
            if storage.canAfford([1,0,0,0]) and monster.health > 0
                new Spark world, base, monster
        for i in [0...8]
            setTimeout func, 1000*i/(world.speed*4)
    
    constructor: (@world, base, @monster) ->
        
        @monster.health -= 1
        # log "monster.health #{@monster.health}"
        storage = @world.storage[base.player]
        storage.deduct [1,0,0,0]
        @path = @world.pathFromPosToPos base.pos, @monster.pos
        geom = new THREE.Geometry
                
        @box = @world.boxes.add pos:@world.posAtIndex(@path[0]), size:0.05, stone:Stone.red
        
        @life = 0
        @animate 0
            
    del: -> 
        @monster.damage 1
        @world.boxes.del @box
        
    animate: (delta) =>
        
        @life += state.spark.speed * delta
        
        if @life > 1
            @life -= 1 
            @path.shift()
            pos = @world.posAtIndex(@path[0])
            if @monster.pos.equals(pos) or @monster.pos.plus(@monster.nxt.mul @monster.moved).dist(pos) < 0.2
                @del()
                return
            if @path.length < 2
                @path = @world.pathFromPosToPos pos, @monster.pos
                
        p = @world.posAtIndex @path[0]
        n = @world.posAtIndex @path[1]
        @world.boxes.setPos @box, p.plus p.to(n).mul @life

        rts.animateWorld @animate
                
module.exports = Spark
