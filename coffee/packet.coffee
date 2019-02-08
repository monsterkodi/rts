###
00000000    0000000    0000000  000   000  00000000  000000000
000   000  000   000  000       000  000   000          000   
00000000   000000000  000       0000000    0000000      000   
000        000   000  000       000  000   000          000   
000        000   000   0000000  000   000  00000000     000   
###

{ deg2rad, log, _ } = require 'kxk'

THREE     = require 'three'
Vector    = require './lib/vector'
Materials = require './materials'

class Packet

    constructor: (@bot, world) ->
        
        @index = 0
        @speed = 1
        @moved = 0
        
        s = 0.125
        geom = new THREE.BoxGeometry s,s,s
        geom.computeFaceNormals()
        geom.rotateX deg2rad 90
        geom.computeFlatVertexNormals()
        geom.translate 
        
        @mesh = new THREE.Mesh geom, @bot.mesh.material
        @mesh.castShadow = true
        @mesh.receiveShadow = true
        world.scene.add @mesh
        
        @tick 0
        
    pathPos: (path, index, moved) ->
        
        ind = path.pind[index]
        ths = path.points[ind]
        nxt = path.points[ind+1]
        if nxt.i > 0 
            if moved < nxt.i
                frc = moved / nxt.i
            else 
                ths = nxt
                nxt = path.points[ind+2]
                if moved < nxt.i
                    frc = (moved-ths.i) / (nxt.i-ths.i)
                else
                    ths = nxt
                    nxt = path.points[ind+3]
                    frc = (moved-ths.i) / (1-ths.i)
        else
            frc = moved
            
        dir = ths.pos.to nxt.pos
        ths.pos.plus dir.mul frc
        
    tick: (delta) =>
        
        if not @bot.path?
            @del()
            return
        
        @moved += delta * @speed
        
        while @moved >= 1
            @index += 1
            @moved -= 1
        
        if @index < @bot.path.length-1
            @mesh.position.copy @pathPos @bot.path, @index, @moved
            
            rts.animate @tick
        else
            @del()
            
    del: -> @mesh.parent.remove @mesh
            
module.exports = Packet
