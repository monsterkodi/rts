###
000   000   0000000   000      000   000  00     00  00000000    
000   000  000   000  000      000   000  000   000  000         
 000 000   000   000  000      000   000  000000000  0000000     
   000     000   000  000      000   000  000 0 000  000         
    0       0000000   0000000   0000000   000   000  00000000    
###

DialButton = require './dialbutton'

class VolumeButton extends DialButton

    constructor: (div) ->
    
        super div, 'volumeButton canvasButtonInline'
        
        @name = 'VolumeButton'
        
        post.on 'volume', @onVolume     
        @onVolume()
            
    setDial: (index) -> rts.sound.setVolume index+6
                
    onVolume: =>
        
        p = vec(0,4,0).rotate vec(0,0,1), 180-45-rts.sound.volumeIndex*22.5
        @dot.position.copy p
        @update()

module.exports = VolumeButton
