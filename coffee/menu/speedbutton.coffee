###
 0000000  00000000   00000000  00000000  0000000    0000000    000   000  000000000  000000000   0000000   000   000
000       000   000  000       000       000   000  000   000  000   000     000        000     000   000  0000  000
0000000   00000000   0000000   0000000   000   000  0000000    000   000     000        000     000   000  000 0 000
     000  000        000       000       000   000  000   000  000   000     000        000     000   000  000  0000
0000000   000        00000000  00000000  0000000    0000000     0000000      000        000      0000000   000   000
###

DialButton = require './dialbutton'

class SpeedButton extends DialButton

    constructor: (div) ->
    
        super div, 'speedButton canvasButtonInline'
        
        @name = 'SpeedButton'
        
        post.on 'worldSpeed', @onWorldSpeed        
        @onWorldSpeed()
            
    setDial: (index) -> rts.world.setSpeed index+6
                
    onWorldSpeed: =>
        
        p = vec(0,4,0).rotate vec(0,0,1), 180-45-rts.world.speedIndex*22.5
        @dot.position.copy p
        @render()

module.exports = SpeedButton
