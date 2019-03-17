###
 0000000   00000000   0000000    000  000000000   0000000  
000   000  000   000  000   000  000     000     000       
000   000  0000000    0000000    000     000     0000000   
000   000  000   000  000   000  000     000          000  
 0000000   000   000  0000000    000     000     0000000   
###

class Orbits

    @botOrbits = {}
    @time = 0
    @vec = new Vector()
    
    @clear: ->
        
        if valid @botOrbits
            for botid,orbits of @botOrbits
                for orbit in orbits
                    @delOrbit orbit
        
        @botOrbits = {}
    
    @animate: (scaledDelta) ->
        
        @time += config.bullet.speed * scaledDelta
        
        if valid @botOrbits
            for botid,orbits of @botOrbits
                bot = world.botWithId botid
                for i in [0...orbits.length]
                    box = orbits[i].box
                    r = i/bot.maxHealth
                    a = 0.4 * Math.sin r * Math.PI
                    x = a * Math.sin r * 6*Math.PI - @time
                    y = a * Math.cos r * 6*Math.PI - @time
                    z = -0.4+0.8*i/bot.maxHealth
                    @vec.set x, y, z
                    @vec.applyQuaternion bot.mesh.quaternion
                    @vec.add bot.pos
                    boxes.setPos box, @vec
                    
    @removeBot: (bot) ->
        
        if valid @botOrbits
            if orbits = @botOrbits[bot.id]
                for orbit in orbits
                    @delOrbit orbit
                delete @botOrbits[bot.id]
                    
    @delOrbit: (orbit) -> boxes.del orbit.box
    
    @spawn: (player, enemy, stone) ->
        
        if enemy.hitPoints <= 0
            @removeBot enemy
            return
        
        @botOrbits[enemy.id] ?= []
        @botOrbits[enemy.id].push box:boxes.add pos:enemy.pos, size:0.025, stone:stone
    
module.exports = Orbits
