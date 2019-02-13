###
0000000    00000000  0000000    000   000   0000000 
000   000  000       000   000  000   000  000      
000   000  0000000   0000000    000   000  000  0000
000   000  000       000   000  000   000  000   000
0000000    00000000  0000000     0000000    0000000 
###

{ elem, clamp, def, log, _ } = require 'kxk'

value = (cfg) ->
    
    lbl = elem class:'label', text:cfg.text, 
    val = elem class:'value', text:cfg.value, click:cfg.reset
    inc = elem class:'incr',  text:'>', click:cfg.incr
    dec = elem class:'decr',  text:'<', click:cfg.decr
    box = elem class:'box',   children: [lbl, dec, val, inc]
    
clampZero = (v,d,m) ->
    v += d
    v = Math.max 0, v
    v = Math.min v, m
    v = 0 if v < 0.01
    v

class Debug

    constructor: () ->

        @elem = elem class:'debug', style:'position:absolute; z-index:1; bottom:0px'

        @elem.appendChild @worldSpeed = value text:'world', value: rts.world.speed.toFixed(1),                      reset:@resetWorldSpeed, incr:@incrWorldSpeed, decr:@decrWorldSpeed
        @elem.appendChild @tubeSpeed  = value text:'tube ', value: rts.world.cfg.science.path.speed.toFixed(1),     reset:@resetTubeSpeed,  incr:@incrTubeSpeed,  decr:@decrTubeSpeed
        @elem.appendChild @pathLength = value text:'path ', value: rts.world.cfg.science.path.length,               reset:@resetPath,       incr:@incrPath,       decr:@decrPath
        @elem.appendChild @tubesGap   = value text:'gap  ', value: (rts.world.cfg.science.path.gap-0.1).toFixed(2), reset:@resetGap,        incr:@incrGap,        decr:@decrGap

        document.body.appendChild @elem

    resetWorldSpeed: => @modWorldSpeed 1-rts.world.speed
    resetTubeSpeed: => @modTubeSpeed 0.5-rts.world.cfg.science.path.speed
    resetPath:     => @modPath 10-rts.world.cfg.science.path.length
    resetGap:      => @modGap 0.12-rts.world.cfg.science.path.gap
    incrTubeSpeed: => @modTubeSpeed  0.1 
    decrTubeSpeed: => @modTubeSpeed -0.1
    modTubeSpeed: (d) -> 
        rts.world.tubes.speed = clampZero rts.world.cfg.science.path.speed, d, 1
        @tubeSpeed.children[2].innerHTML = rts.world.cfg.science.path.speed.toFixed 1

    incrWorldSpeed: => @modWorldSpeed rts.world.speed >= 1 and 1 or 0.1 
    decrWorldSpeed: => @modWorldSpeed rts.world.speed > 1 and -1 or -0.1
    modWorldSpeed: (d) -> 
        rts.world.speed = clampZero rts.world.speed, d, 10
        @worldSpeed.children[2].innerHTML = rts.world.speed.toFixed 1

    incrGap: => @modGap  0.01 
    decrGap: => @modGap -0.01
    modGap: (d) -> 
        rts.world.cfg.science.path.gap += d
        rts.world.cfg.science.path.gap = clamp 0.1, 0.5, rts.world.cfg.science.path.gap
        @tubesGap.children[2].innerHTML = (rts.world.cfg.science.path.gap-0.1).toFixed(2)

    incrPath: => @modPath  1 
    decrPath: => @modPath -1
    modPath: (d) -> 
        rts.world.cfg.science.path.length += d
        rts.world.cfg.science.path.length = clamp 1, 40, rts.world.cfg.science.path.length
        @pathLength.children[2].innerHTML = rts.world.cfg.science.path.length
        rts.world.tubes.build()
        rts.world.construct.tubes()
        
module.exports = Debug
