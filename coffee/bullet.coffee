###
0000000    000   000  000      000      00000000  000000000  
000   000  000   000  000      000      000          000     
0000000    000   000  000      000      0000000      000     
000   000  000   000  000      000      000          000     
0000000     0000000   0000000  0000000  00000000     000     
###

Orbits = require './orbits'

class Bullet

    @botBullets = {}
    @bulletid = 0
    
    @clear: ->
        
        if valid @botBullets
            for botid,bullets of @botBullets
                for bulletid,bullet of bullets
                    bullet.del()
        
        @botBullets = {}
        @bulletid = 0
    
    @animate: (scaledDelta) ->

        if valid @botBullets
            for botid,bullets of @botBullets
                for bulletid,bullet of bullets
                    bullet.animate scaledDelta
            
    @spawn: (berta, enemy, stone) ->
        
        storage = world.storage[berta.player]
        
        path = world.bulletPath berta, enemy
        return if not path
        
        @botBullets[enemy.id] ?= {}
        
        for i in [0...config.bullet.count]
            return if not storage.has stone 
            return if enemy.health <= 0
            storage.sub stone
            enemy.health -= 1
            life = -i*1/config.bullet.count
            id = @bulletid++
            @botBullets[enemy.id][id] = new Bullet id, berta, enemy, stone, _.clone(path), life
    
    constructor: (@id, berta, @enemy, @stone, @path, @life) ->
        
        @player = berta.player
        @pos = vec berta.pos
        @dir = vec()
        @vec = vec()
        @updateDir()
                
        @box = boxes.add pos:@pos, size:0.05, stone:@stone
        
    del: -> 
    
        boxes.del @box
        delete Bullet.botBullets[@enemy.id][@id]
        
    updatePath: -> @path = world.bulletPath @, @enemy
    updateDir: ->
        
        world.indexToPos @path[1], @dir
        @dir.sub @pos
        if @path.length == 2
            @dir.scale 0.75
                    
    startOrbit: ->
        
        handle.enemyDamage @enemy, 1
        Orbits.spawn @player, @enemy
        @del()
        
    animate: (scaledDelta) ->
        
        @life += config.bullet.speed * scaledDelta
        
        return if @life < 0
                
        if @life > 1
            @life -= 1 
            @path.shift()
            world.indexToPos @path[0], @pos
            if @enemy.pos.equals @pos
                @startOrbit()
                return
            if @path.length < 2 
                @updatePath()
                if not @path
                    @del()
                    return
            @updateDir()

        @vec.copy  @dir
        @vec.scale @life
        @vec.add   @pos
        boxes.setPos @box, @vec
                
module.exports = Bullet
