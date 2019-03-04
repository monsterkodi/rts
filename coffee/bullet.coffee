###
0000000    000   000  000      000      00000000  000000000  
000   000  000   000  000      000      000          000     
0000000    000   000  000      000      0000000      000     
000   000  000   000  000      000      000          000     
0000000     0000000   0000000  0000000  00000000     000     
###

class Bullet

    @spawn: (world, berta, enemy) ->
        
        storage = world.storage[berta.player]
        
        func = -> 
            if storage.has(config.bullet.stone) and enemy.health > 0
                new Bullet world, berta, enemy
        for i in [0...config.bullet.count]
            setTimeout func, 1000*config.bullet.delay*i/world.speed
    
    constructor: (@world, berta, @enemy) ->
        
        @enemy.health -= 1
        # log "enemy.health #{@enemy.health}"
        storage = @world.storage[berta.player]
        storage.sub config.bullet.stone
        @pos = vec berta.pos
        @updatePath()
        if not @path
            # log "ok? no path for bullet? #{str berta.pos} #{str @enemy.pos}"
            return
        @dir = vec()
        @updateDir()
                
        @box = @world.boxes.add pos:@pos, size:0.05, stone:config.bullet.stone
        @life = 0
        @animate 0
        
    updatePath: -> @path = @world.bulletPath @, @enemy
    updateDir: ->
        
        @world.indexToPos @path[1], @dir
        @dir.sub @pos
        if @path.length == 2
            @dir.scale 0.75
            
    del: -> 
        rts.handle.enemyDamage @enemy, 1
        @world.boxes.del @box
        
    animate: (delta) =>
        
        @life += config.bullet.speed * delta
        
        if @life > 1
            @life -= 1 
            @path.shift()
            @world.indexToPos @path[0], @pos
            if @enemy.pos.equals @pos
                @del()
                return
            if @path.length < 2 
                @updatePath()
                if not @path
                    @del()
                    return
            @updateDir()

        @world.boxes.setPos @box, @pos.plus @dir.mul @life

        rts.animateWorld @animate
                
module.exports = Bullet
