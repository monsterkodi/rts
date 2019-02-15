###
0000000    00000000  0000000    000   000   0000000 
000   000  000       000   000  000   000  000      
000   000  0000000   0000000    000   000  000  0000
000   000  000       000   000  000   000  000   000
0000000    00000000  0000000     0000000    0000000 
###

{ elem, clamp, def, log, _ } = require 'kxk'

class Debug

    constructor: () ->

        @elem = elem class:'debug', style:'position:absolute; z-index:1; bottom:10px; left:10px;'

        @elem.appendChild @worldSpeed = @value text:'world', value: rts.world.speed.toFixed(1),                      reset:@resetWorldSpeed, incr:@incrWorldSpeed, decr:@decrWorldSpeed
        @elem.appendChild @tubeSpeed  = @value text:'tube ', value: rts.world.config.science.path.speed.toFixed(1),     reset:@resetTubeSpeed,  incr:@incrTubeSpeed,  decr:@decrTubeSpeed
        @elem.appendChild @pathLength = @value text:'path ', value: rts.world.config.science.path.length,               reset:@resetPath,       incr:@incrPath,       decr:@decrPath
        @elem.appendChild @tubesGap   = @value text:'gap  ', value: rts.world.config.science.path.gap.toFixed(2), reset:@resetGap,        incr:@incrGap,        decr:@decrGap

        document.body.appendChild @elem

    del: -> @elem.remove()
        
    # 00000000   00000000   0000000  00000000  000000000  
    # 000   000  000       000       000          000     
    # 0000000    0000000   0000000   0000000      000     
    # 000   000  000            000  000          000     
    # 000   000  00000000  0000000   00000000     000     
    
    resetWorldSpeed: => @modWorldSpeed 1-rts.world.speed
    resetTubeSpeed:  => @modTubeSpeed 0.5-rts.world.config.science.path.speed
    resetPath:       => @modPath 10-rts.world.config.science.path.length
    resetGap:        => @modGap 0.12-rts.world.config.science.path.gap
    
    # 000000000  000   000  0000000    00000000  
    #    000     000   000  000   000  000       
    #    000     000   000  0000000    0000000   
    #    000     000   000  000   000  000       
    #    000      0000000   0000000    00000000  
    
    incrTubeSpeed: => @modTubeSpeed  0.1 
    decrTubeSpeed: => @modTubeSpeed -0.1
    modTubeSpeed: (d) -> 
        rts.world.config.science.path.speed = @clampZero rts.world.config.science.path.speed, d, 1
        @tubeSpeed.children[2].innerHTML = rts.world.config.science.path.speed.toFixed 1

    # 000   000   0000000   00000000   000      0000000    
    # 000 0 000  000   000  000   000  000      000   000  
    # 000000000  000   000  0000000    000      000   000  
    # 000   000  000   000  000   000  000      000   000  
    # 00     00   0000000   000   000  0000000  0000000    
    
    incrWorldSpeed: => @modWorldSpeed rts.world.speed >= 1 and 1 or 0.1 
    decrWorldSpeed: => @modWorldSpeed rts.world.speed > 1 and -1 or -0.1
    modWorldSpeed: (d) -> 
        rts.world.speed = @clampZero rts.world.speed, d, 10
        @worldSpeed.children[2].innerHTML = rts.world.speed.toFixed 1

    #  0000000    0000000   00000000   
    # 000        000   000  000   000  
    # 000  0000  000000000  00000000   
    # 000   000  000   000  000        
    #  0000000   000   000  000        
    
    incrGap: => @modGap  0.01 
    decrGap: => @modGap -0.01
    modGap: (d) -> 
        rts.world.config.science.path.gap += d
        rts.world.config.science.path.gap = clamp 0.1, 0.5, rts.world.config.science.path.gap
        @tubesGap.children[2].innerHTML = rts.world.config.science.path.gap.toFixed(2)

    # 00000000    0000000   000000000  000   000  
    # 000   000  000   000     000     000   000  
    # 00000000   000000000     000     000000000  
    # 000        000   000     000     000   000  
    # 000        000   000     000     000   000  
    
    incrPath: => @modPath  1 
    decrPath: => @modPath -1
    modPath: (d) -> 
        rts.world.config.science.path.length += d
        rts.world.config.science.path.length = clamp 1, 40, rts.world.config.science.path.length
        @pathLength.children[2].innerHTML = rts.world.config.science.path.length
        rts.world.updateTubes()
        
    # 000   000   0000000   000      000   000  00000000  
    # 000   000  000   000  000      000   000  000       
    #  000 000   000000000  000      000   000  0000000   
    #    000     000   000  000      000   000  000       
    #     0      000   000  0000000   0000000   00000000  
    
    value: (cfg) ->
        
        lbl = elem class:'label', text:cfg.text, 
        val = elem class:'value', text:cfg.value, click:cfg.reset
        inc = elem class:'incr',  text:'>', click:cfg.incr
        dec = elem class:'decr',  text:'<', click:cfg.decr
        box = elem class:'box',   children: [lbl, dec, val, inc]
        
    #  0000000  000       0000000   00     00  00000000   0000000  00000000  00000000    0000000   
    # 000       000      000   000  000   000  000   000     000   000       000   000  000   000  
    # 000       000      000000000  000000000  00000000     000    0000000   0000000    000   000  
    # 000       000      000   000  000 0 000  000         000     000       000   000  000   000  
    #  0000000  0000000  000   000  000   000  000        0000000  00000000  000   000   0000000   
    
    clampZero: (v,d,m) ->
        v += d
        v = Math.max 0, v
        v = Math.min v, m
        v = 0 if v < 0.01
        v
            
module.exports = Debug
