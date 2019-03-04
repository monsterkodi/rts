###
00000000    0000000    0000000  000   000  00000000  000000000
000   000  000   000  000       000  000   000          000   
00000000   000000000  000       0000000    0000000      000   
000        000   000  000       000  000   000          000   
000        000   000   0000000  000   000  00000000     000   
###

class Packet

    constructor: (@stone, @player, world) ->
        
        @moved = 0
        
        size = 0.001
        
        @box = world.boxes.add stone:@stone, size:size, pos:vec()
        
        @lifeTime = 0
        rts.animate @initialScale
        
    #  0000000   0000000   0000000   000      00000000  
    # 000       000       000   000  000      000       
    # 0000000   000       000000000  000      0000000   
    #      000  000       000   000  000      000       
    # 0000000    0000000  000   000  0000000  00000000  
    
    initialScale: (deltaSeconds) =>

        return if not @box
        @lifeTime += deltaSeconds * rts.world.speed
        timeOrTravel = clamp 0, 1, Math.max @lifeTime, @moved*5
        size = Math.min timeOrTravel*0.1, 0.1
        
        rts.world.boxes.setSize @box, size
        
        if size < 0.1
            rts.animate @initialScale            
        
    # 00     00   0000000   000   000  00000000  
    # 000   000  000   000  000   000  000       
    # 000000000  000   000   000 000   0000000   
    # 000 0 000  000   000     000     000       
    # 000   000   0000000       0      00000000  
    
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
            
        # dir = ths.pos.to nxt.pos
        # tgt = ths.pos.plus dir.mul frc
        tgt = vec nxt.pos
        tgt.sub ths.pos
        tgt.scale frc
        tgt.add ths.pos
        
        # log "#{@player} #{Stone.string @stone} #{tgt.x} #{tgt.y} #{tgt.z}"
        
        rts.world.boxes.setPos @box, tgt
        
    # 0000000    00000000  000      
    # 000   000  000       000      
    # 000   000  0000000   000      
    # 000   000  000       000      
    # 0000000    00000000  0000000  
    
    del: -> 
    
        rts.world.boxes.del @box
        rts.world.storage[@player].temp[@stone] -= 1
        delete @box
            
module.exports = Packet
