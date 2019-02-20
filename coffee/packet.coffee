###
00000000    0000000    0000000  000   000  00000000  000000000
000   000  000   000  000       000  000   000          000   
00000000   000000000  000       0000000    0000000      000   
000        000   000  000       000  000   000          000   
000        000   000   0000000  000   000  00000000     000   
###

{ deg2rad, empty, clamp, log, _ } = require 'kxk'

THREE     = require 'three'
Vector    = require './lib/vector'
Materials = require './materials'

class Packet

    constructor: (@stone, world) ->
        
        @moved = 0
        
        s = 0.001
        geom = new THREE.BoxGeometry s,s,s
         
        @mesh = new THREE.Mesh geom, Materials.stone[@stone]
        @mesh.castShadow = true
        @mesh.receiveShadow = true
        world.scene.add @mesh
        
        @lifeTime = 0
        rts.animate @initialScale
        
    initialScale: (deltaSeconds) =>

        @lifeTime += deltaSeconds * rts.world.speed
        @mesh.geometry.normalize()
        timeOrTravel = clamp 0, 1, Math.max @lifeTime, @moved*5
        s = Math.min timeOrTravel*0.1, 0.1
        @mesh.geometry.scale s,s,s
        if s < 0.1
            rts.animate @initialScale            
        
    move: (delta) -> @moved += delta
            
    moveOnSegment: (seg) ->
        
        points = seg.points
        return if empty points
        ind = 0
        ths = points[ind]
        nxt = points[ind+1]
        factor = @moved/seg.moves
        if nxt.i > 0 
            if factor < nxt.i
                frc = factor / nxt.i
            else 
                ths = nxt
                nxt = points[ind+2]
                if factor < nxt.i
                    frc = (factor-ths.i) / (nxt.i-ths.i)
                else
                    ths = nxt
                    nxt = points[ind+3]
                    frc = (factor-ths.i) / (1-ths.i)
        else
            frc = factor
            
        dir = ths.pos.to nxt.pos
        tgt = ths.pos.plus dir.mul frc
        
        @mesh.position.copy tgt
    
    del: -> 
    
        @mesh.parent.remove @mesh
        rts.world.storage.temp[@stone] -= 1
            
module.exports = Packet
