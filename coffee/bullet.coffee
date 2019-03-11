###
0000000    000   000  000      000      00000000  000000000  
000   000  000   000  000      000      000          000     
0000000    000   000  000      000      0000000      000     
000   000  000   000  000      000      000          000     
0000000     0000000   0000000  0000000  00000000     000     
###

class Bullet

    @spawn: (world, berta, enemy, stone) ->
        
        storage = world.storage[berta.player]
        
        func = -> 
            if storage.has(stone) and enemy.health > 0
                new Bullet world, berta, enemy, stone
        for i in [0...config.bullet.count]
            setTimeout func, 1000*config.bullet.delay*i/world.speed
    
    constructor: (@world, berta, @enemy, @stone) ->
        
        @enemy.health -= 1
        # log "enemy.health #{@enemy.health}"
        @player = berta.player
        storage = @world.storage[@player]
        storage.sub @stone
        @pos = vec berta.pos
        @updatePath()
        if not @path
            # log "ok? no path for bullet? #{str berta.pos} #{str @enemy.pos}"
            return
        @dir = vec()
        @vec = vec()
        @updateDir()
                
        @box = @world.boxes.add pos:@pos, size:0.05, stone:@stone
        @life = 0
        @animate 0
        
    updatePath: -> @path = @world.bulletPath @, @enemy
    updateDir: ->
        
        @world.indexToPos @path[1], @dir
        @dir.sub @pos
        if @path.length == 2
            @dir.scale 0.75
            
    del: -> @world.boxes.del @box
        
    startOrbit: ->
        
        rts.handle.enemyDamage @enemy, 1
        
        @orbiting = true
        
        @world.boxes.setSize @box, 0.025
        @world.boxes.setColor @box, Color.orbits[@player]
        @world.boxes.pos @box, @vec
        @vec.sub @enemy.pos
        @pos.copy @vec
        @pos.normalize()
        @pos.scale 0.5
        @vec.normalize()
        @dir.randomize()
        @dir.cross @vec
        
    animate: (delta) =>
        
        @life += config.bullet.speed * delta
        
        if @orbiting
            
            if @enemy.hitPoints <= 1
                @del()
                return
            
            @pos.applyQuaternion Quaternion.axisAngle @dir, delta*9
            @vec.copy @pos
            @vec.add @enemy.pos
            @world.boxes.setPos @box, @vec
            rts.animateWorld @animate
            return
        
        if @life > 1
            @life -= 1 
            @path.shift()
            @world.indexToPos @path[0], @pos
            if @enemy.pos.equals @pos
                @startOrbit()
                rts.animateWorld @animate
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
        @world.boxes.setPos @box, @vec

        rts.animateWorld @animate
                
module.exports = Bullet
