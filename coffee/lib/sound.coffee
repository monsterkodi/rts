###
 0000000   0000000   000   000  000   000  0000000    
000       000   000  000   000  0000  000  000   000  
0000000   000   000  000   000  000 0 000  000   000  
     000  000   000  000   000  000  0000  000   000  
0000000    0000000    0000000   000   000  0000000    
###

{ randRange } = require 'kxk'

Synt = require './synt'

class Sound

    constructor: () ->

        @volumeIndex = 3
        @volume = 0
        
        @ctx = new (window.AudioContext || window.webkitAudioContext)()
        
        @gain = @ctx.createGain()
        @gain.connect @ctx.destination
        
        # piano1, piano2, piano3, piano4, piano5
        # string, flute
        # bell1, bell2, bell3, bell4
        # organ1, organ2
        
        @synt = {}
        @setSynt
            enemy:   instrument: 'bell3'
            player:  instrument: 'bell3'
            menu:    instrument: 'flute'
            stone:   instrument: 'bell1'
            science: instrument: 'bell2'
            state:   instrument: 'bell4'
            fail:    instrument: 'string'
            
        @setVolume prefs.get 'volume', @volumeIndex

    play: (o,n,c=0) ->
        @synt[o].playNote switch n
            when 'won'  then 5*12+c+parseInt randRange 0,4
            when 'lost' then 6*12+c+parseInt randRange 0,2
            when 'highlight' then 40+c 
            when 'enqueue'   then 55+c 
            when 'off'       then 50+c 
            when 'on'        then 60+c 
            when 'stone'     then 45+c 
            else
                6*12+c+parseInt randRange 0,2
            
    setSynt: (synt) ->
        # log 'setSynt', JSON.stringify synt
        for k,v of synt
            @synt[k] = new Synt v, @ctx, @gain
             
    setVolume: (volumeIndex) -> 
        
        @volumeIndex = clamp 0, config.volume.length-1, volumeIndex
        @volume = config.volume[@volumeIndex]
        @gain.gain.value = @volume
        prefs.set 'volume', @volumeIndex
        post.emit 'volume', @volumeIndex

module.exports = Sound        
