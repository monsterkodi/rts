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

        @elem.appendChild @worldSpeed = value text:'world', value: rts.world.speed.toFixed(1),       reset:@resetWorldSpeed, incr:@incrWorldSpeed, decr:@decrWorldSpeed
        @elem.appendChild @tubeSpeed  = value text:'tube ', value: rts.world.tubes.speed.toFixed(1), reset:@resetTubeSpeed,  incr:@incrTubeSpeed,  decr:@decrTubeSpeed
        @elem.appendChild @botSpeed   = value text:'bots ', value: rts.world.botSpeed.toFixed(1),    reset:@resetBotSpeed,   incr:@incrBotSpeed,   decr:@decrBotSpeed
        @elem.appendChild @pathLength = value text:'path ', value: rts.world.science.maxPathLength,  reset:@resetPath,       incr:@incrPath,       decr:@decrPath
        @elem.appendChild @tubesGap   = value text:'gap  ', value: rts.world.tubes.gap.toFixed(2),   reset:@resetGap,        incr:@incrGap,        decr:@decrGap

        document.body.appendChild @elem

    resetWorldSpeed: => @modWorldSpeed 1-rts.world.speed
    resetTubeSpeed: => @modTubeSpeed 0.5-rts.world.tubes.speed
    resetBotSpeed: => @modBotSpeed 1-rts.world.botSpeed
    resetPath:     => @modPath 10-rts.world.science.maxPathLength
    resetGap:      => @modGap 0.12-rts.world.tubes.gap
    incrTubeSpeed: => @modTubeSpeed  0.1 
    decrTubeSpeed: => @modTubeSpeed -0.1
    modTubeSpeed: (d) -> 
        rts.world.tubes.speed = clampZero rts.world.tubes.speed, d, 1
        @tubeSpeed.children[2].innerHTML = rts.world.tubes.speed.toFixed 1

    incrBotSpeed: => @modBotSpeed  0.1 
    decrBotSpeed: => @modBotSpeed -0.1
    modBotSpeed: (d) -> 
        rts.world.botSpeed = clampZero rts.world.botSpeed, d, 4
        for bot in rts.world.getBots()
            bot.speed = rts.world.botSpeed
        @botSpeed.children[2].innerHTML = rts.world.botSpeed.toFixed 1

    incrWorldSpeed: => @modWorldSpeed rts.world.speed >= 1 and 1 or 0.1 
    decrWorldSpeed: => @modWorldSpeed rts.world.speed > 1 and -1 or -0.1
    modWorldSpeed: (d) -> 
        rts.world.speed = clampZero rts.world.speed, d, 10
        @worldSpeed.children[2].innerHTML = rts.world.speed.toFixed 1

    incrGap: => @modGap  0.01 
    decrGap: => @modGap -0.01
    modGap: (d) -> 
        rts.world.tubes.gap += d
        rts.world.tubes.gap = clamp 0.1, 0.5, rts.world.tubes.gap
        @tubesGap.children[2].innerHTML = rts.world.tubes.gap.toFixed 2

    incrPath: => @modPath  1 
    decrPath: => @modPath -1
    modPath: (d) -> 
        rts.world.science.maxPathLength += d
        rts.world.science.maxPathLength = clamp 1, 40, rts.world.science.maxPathLength
        @pathLength.children[2].innerHTML = rts.world.science.maxPathLength
        rts.world.tubes.build()
        rts.world.construct.tubes()
        
module.exports = Debug
