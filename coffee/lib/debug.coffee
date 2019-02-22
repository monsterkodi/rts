###
0000000    00000000  0000000    000   000   0000000 
000   000  000       000   000  000   000  000      
000   000  0000000   0000000    000   000  000  0000
000   000  000       000   000  000   000  000   000
0000000    00000000  0000000     0000000    0000000 
###

{ post, elem, clamp, def, log, _ } = require 'kxk'

class Debug

    constructor: () ->

        @elem = elem class:'debug', style:'position:absolute; z-index:1; bottom:10px; left:10px;'

        window.debug = 
            cheapScience: false
            fastScience: false
        
        # @worldSpeed = @value text:'world', value: rts.world.speed.toFixed(1),          reset:@resetWorldSpeed, incr:@incrWorldSpeed, decr:@decrWorldSpeed
        # @tubeSpeed  = @value text:'tube ', value: state.science.tube.speed.toFixed(1), reset:@resetTubeSpeed,  incr:@incrTubeSpeed,  decr:@decrTubeSpeed
        # @tubesGap   = @value text:'gap  ', value: state.science.tube.gap.toFixed(2),   reset:@resetGap,        incr:@incrGap,        decr:@decrGap
        @pathLength = @value text:'path ', value: state.science.path.length,           reset:@resetPath,       incr:@incrPath,       decr:@decrPath
        @button text:'fill  storage', cb: -> rts.world.storage.fill()
        @button text:'clear storage', cb: -> rts.world.storage.clear()
        @toggle text:'cheap science', obj:window.debug, key:'cheapScience'
        @toggle text:'fast  science', obj:window.debug, key:'fastScience'

        document.body.appendChild @elem
        
        post.on 'worldSpeed', @updateWorldSpeed

    del: -> 
    
        post.removeListener 'worldSpeed', @updateWorldSpeed
        @elem.remove()
        
    # 00000000   00000000   0000000  00000000  000000000  
    # 000   000  000       000       000          000     
    # 0000000    0000000   0000000   0000000      000     
    # 000   000  000            000  000          000     
    # 000   000  00000000  0000000   00000000     000     
    
    resetWorldSpeed: => rts.world.resetSpeed()
    resetTubeSpeed:  => @modTubeSpeed 0.5-state.science.tube.speed
    resetPath:       => @modPath 10-state.science.path.length
    resetGap:        => @modGap 0.12-state.science.tube.gap
    
    # 000000000  000   000  0000000    00000000  
    #    000     000   000  000   000  000       
    #    000     000   000  0000000    0000000   
    #    000     000   000  000   000  000       
    #    000      0000000   0000000    00000000  
    
    incrTubeSpeed: => @modTubeSpeed  0.1 
    decrTubeSpeed: => @modTubeSpeed -0.1
    modTubeSpeed: (d) -> 
        state.science.tube.speed = @clampZero state.science.tube.speed, d, 1
        @tubeSpeed.children[2].innerHTML = state.science.tube.speed.toFixed 1

    # 000   000   0000000   00000000   000      0000000    
    # 000 0 000  000   000  000   000  000      000   000  
    # 000000000  000   000  0000000    000      000   000  
    # 000   000  000   000  000   000  000      000   000  
    # 00     00   0000000   000   000  0000000  0000000    
    
    incrWorldSpeed: => rts.world.incrSpeed()
    decrWorldSpeed: => rts.world.decrSpeed()
    updateWorldSpeed: =>  @worldSpeed.children[2].innerHTML = rts.world.speed.toFixed 1

    #  0000000    0000000   00000000   
    # 000        000   000  000   000  
    # 000  0000  000000000  00000000   
    # 000   000  000   000  000        
    #  0000000   000   000  000        
    
    incrGap: => @modGap  0.01 
    decrGap: => @modGap -0.01
    modGap: (d) -> 
        state.science.tube.gap += d
        state.science.tube.gap = clamp 0.1, 0.5, state.science.tube.gap
        @tubesGap.children[2].innerHTML = state.science.tube.gap.toFixed(2)

    # 00000000    0000000   000000000  000   000  
    # 000   000  000   000     000     000   000  
    # 00000000   000000000     000     000000000  
    # 000        000   000     000     000   000  
    # 000        000   000     000     000   000  
    
    incrPath: => @modPath  1 
    decrPath: => @modPath -1
    modPath: (d) -> 
        state.science.path.length += d
        state.science.path.length = clamp 1, 40, state.science.path.length
        @pathLength.children[2].innerHTML = state.science.path.length
        rts.world.updateTubes()
        
    value: (cfg) ->
        
        lbl = elem class:'label', text:cfg.text
        val = elem class:'value', text:cfg.value, click:cfg.reset
        inc = elem class:'incr',  text:'>', click:cfg.incr
        dec = elem class:'decr',  text:'<', click:cfg.decr
        box = elem class:'box',   children: [lbl, dec, val, inc], parent:@elem
        
    button: (cfg) -> elem class:'btn', text:cfg.text, click:cfg.cb, parent:@elem
    toggle: (cfg) -> 
        tgl = (cfg) -> (event) -> 
            cfg.obj[cfg.key] = !cfg.obj[cfg.key]
            event.target.innerHTML = cfg.text + " #{cfg.obj[cfg.key] and 'on' or 'off'}"
            cfg.cb? cfg.obj[cfg.key]
        btn = elem class:'btn', text:cfg.text+" #{cfg.obj[cfg.key] and 'on' or 'off'}", click:tgl(cfg), parent:@elem
        
    clampZero: (v,d,m) ->
        v += d
        v = Math.max 0, v
        v = Math.min v, m
        v = 0 if v < 0.01
        v
            
module.exports = Debug
