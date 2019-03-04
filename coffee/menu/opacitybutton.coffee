###
 0000000   00000000    0000000    0000000  000  000000000  000   000    
000   000  000   000  000   000  000       000     000      000 000     
000   000  00000000   000000000  000       000     000       00000      
000   000  000        000   000  000       000     000        000       
 0000000   000        000   000   0000000  000     000        000       
###

DialButton = require './dialbutton'

class OpacityButton extends DialButton

    constructor: (div) ->
    
        super div, 'opacityButton canvasButtonInline'
        
        @name = 'OpacityButton'
        
        post.on 'worldOpacity', @onWorldOpacity        
        @onWorldOpacity()
            
    setDial: (index) -> rts.world.setOpacity index+6
                
    onWorldOpacity: =>
        
        p = vec(0,4,0).rotate vec(0,0,1), 180-45-rts.world.opacityIndex*22.5
        @dot.position.copy p
        @render()

module.exports = OpacityButton
