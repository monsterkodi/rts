###
00000000   000       0000000    0000000  000   0000000   000   000  
000   000  000      000   000  000       000  000   000  0000  000  
00000000   000      000   000  0000000   000  000   000  000 0 000  
000        000      000   000       000  000  000   000  000  0000  
000        0000000   0000000   0000000   000   0000000   000   000  
###

{ randRange, fade } = require 'kxk'

Boxes = require './boxes'

class Plosion

    constructor: ->

        @vec = vec()
        geom = new THREE.TetrahedronGeometry 1
        geom = new THREE.BufferGeometry().fromGeometry geom
        @boxes = new Boxes world.scene, 3000, geom, Materials.cage, true
        @plosions = []
        
    atBot: (bot) ->

        if bot.player
            color = Color.cage.player.berta
        else
            color = Color.cage.enemy.berta
        
        @atPos bot.pos, 0.2, color
        
    atPos: (pos, scale, color, startSize) ->
        
        plosion = age:0, shrapnels:[]
        plosion.startSize = startSize ? config.plosion.minSize
        
        for i in [0...config.plosion.shrapnels]
            dir = Vector.random()
            dir.scale scale
            @vec.copy pos
            @vec.add dir
            box = @boxes.add color:color, pos:@vec, size:plosion.startSize
            dir.scale config.plosion.maxDist/scale
            box.dir = dir
            box.pos = @vec.clone()
            @vec.randomize()
            box.rot = quat().setFromAxisAngle @vec, world.speed * randRange(config.plosion.minRot, config.plosion.maxRot)
            plosion.shrapnels.push box
            
        @plosions.push plosion
        
    animate: (scaledDelta) ->
        
        return if empty @plosions
        
        for plosionIndex in [@plosions.length-1..0]
        
            plosion = @plosions[plosionIndex]
            plosion.age += scaledDelta
            
            ageFactor = plosion.age / config.plosion.maxAge
            fadeFactor = 1-(Math.cos(Math.PI*2*ageFactor)*0.5+0.5)
            moveFactor = Math.sin(Math.PI*0.5*ageFactor)
            if ageFactor < 0.5
                size = fade plosion.startSize, config.plosion.maxSize, fadeFactor
            else
                size = fade 0, config.plosion.maxSize, fadeFactor
            
            if plosion.age <= config.plosion.maxAge
                for i in [plosion.shrapnels.length-1..0]
                    box = plosion.shrapnels[i]
                    @vec.copy box.dir
                    @vec.scale moveFactor
                    @vec.add box.pos
                                    
                    @boxes.setPos  box, @vec
                    @boxes.setSize box, size
                    @boxes.setRot  box, @boxes.rot(box).multiply box.rot
            else
                for box in plosion.shrapnels
                    @boxes.del box
                @plosions.splice plosionIndex, 1
        
        @boxes.render()
        
module.exports = Plosion
