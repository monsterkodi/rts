###
 0000000   00000000   0000000    000  000000000   0000000  
000   000  000   000  000   000  000     000     000       
000   000  0000000    0000000    000     000     0000000   
000   000  000   000  000   000  000     000          000  
 0000000   000   000  0000000    000     000     0000000   
###

class Orbits

    @botOrbits = {}
    @orbitid = 0
    @time = 0
    
    @clear: ->
        
        if valid @botOrbits
            for botid,orbits of @botOrbits
                for orbitid,orbit of orbits
                    @delOrbit orbit
        
        @botOrbits = {}
        @orbitid = 0
    
    @animate: (scaledDelta) ->
        
        @time += config.bullet.speed * scaledDelta
        
        if valid @botOrbits
            for botid,orbits of @botOrbits
                for orbitid,orbit of orbits
    
                    @pos.applyQuaternion Quaternion.axisAngle @dir, scaledDelta*9
                    @vec.copy @pos
                    @vec.add @enemy.pos
                    boxes.setPos @box, @vec
                    
    @removeBot: (bot) ->
        
        if valid @botOrbits
            if orbits = @botOrbits[bot.id]
                for orbit in orbits
                    @delOrbit orbit
                delete @botOrbits[bot.id]
                    
    @delOrbit: (orbit) -> boxes.del orbit.box
    
    @spawn: (player, enemy) ->
        
        if enemy.hitPoints <= 0
            @removeBot enemy
            return
        
        @botOrbits[enemy.id] ?= {}
        id = @orbitid++
        
        box = boxes.add pos:enemy.pos, size:0.025, color:Color.orbits[player]
        
        @botOrbits[enemy.id][id] = box:box
    
module.exports = Orbits
