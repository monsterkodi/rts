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

    constructor: (@world) ->

        @vec = vec()
        geom = new THREE.TetrahedronGeometry 1
        geom = new THREE.BufferGeometry().fromGeometry geom
        @boxes = new Boxes @world.scene, 3000, geom, Materials.cage, true
        @shrapnels = []
        
    atBot: (bot) ->

        if bot.player
            color = Color.cage.player.berta
        else
            color = Color.cage.enemy.berta
        
        for i in [0...config.plosion.shrapnels]
            dir = Vector.random()
            dir.scale 0.2
            pos = vec bot.pos
            pos.add dir
            box = @boxes.add color:color, pos:pos, size:0.001
            dir.scale 5*config.plosion.maxDist
            box.dir = dir
            box.pos = pos
            box.age = 0
            @vec.randomize()
            box.rot = quat().setFromAxisAngle @vec, @world.speed * randRange(config.plosion.minRot, config.plosion.maxRot)
            @shrapnels.push box
        
    animate: (scaledDelta) ->
        
        return if empty @shrapnels
        
        for i in [@shrapnels.length-1..0]
            box = @shrapnels[i]
            box.age += scaledDelta        
            if box.age <= config.plosion.maxAge
                ageFactor = box.age / config.plosion.maxAge
                @vec.copy box.dir
                @vec.scale ageFactor
                @vec.add box.pos
                @boxes.setPos  box, @vec
                @boxes.setSize box, fade config.plosion.minSize, config.plosion.maxSize, 1-(Math.cos(Math.PI*2*ageFactor)*0.5+0.5)
                @boxes.setRot  box, @boxes.rot(box).multiply box.rot
            else
                @boxes.del box
                @shrapnels.splice i, 1
        
        @boxes.render()
        
module.exports = Plosion
