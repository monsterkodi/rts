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

    constructor: (bot, world) ->
        
        @stone = world.stoneBelowBot bot
        @moved = 0
        
        s = 0.1
        geom = new THREE.BoxGeometry s,s,s
         
        @mesh = new THREE.Mesh geom, Materials.stone[@stone]
        @mesh.castShadow = true
        @mesh.receiveShadow = true
        world.scene.add @mesh
        
    moveOnSegment: (segment) ->
        
        points = segment.points
        ind = 0
        ths = points[ind]
        nxt = points[ind+1]
        if nxt.i > 0 
            if @moved < nxt.i
                frc = @moved / nxt.i
            else 
                ths = nxt
                nxt = points[ind+2]
                if @moved < nxt.i
                    frc = (@moved-ths.i) / (nxt.i-ths.i)
                else
                    ths = nxt
                    nxt = points[ind+3]
                    frc = (@moved-ths.i) / (1-ths.i)
        else
            frc = @moved
            
        dir = ths.pos.to nxt.pos
        tgt = ths.pos.plus dir.mul frc
        
        @mesh.position.copy tgt
    
    del: -> @mesh.parent.remove @mesh
            
module.exports = Packet
