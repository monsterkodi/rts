###
 0000000   0000000    0000000   00000000        0000000    000   000  000000000  000000000   0000000   000   000  
000       000   000  000        000             000   000  000   000     000        000     000   000  0000  000  
000       000000000  000  0000  0000000         0000000    000   000     000        000     000   000  000 0 000  
000       000   000  000   000  000             000   000  000   000     000        000     000   000  000  0000  
 0000000  000   000   0000000   00000000        0000000     0000000      000        000      0000000   000   000  
###

DialButton = require './dialbutton'

class CageButton extends DialButton

    constructor: (div) ->
    
        super div, 'cageButton canvasButtonInline'
        
        @name = 'CageButton'
        
        post.on 'cageOpacity', @onCageOpacity        
        @onCageOpacity()
            
    setDial: (index) -> world.setCageOpacity index+6
                
    onCageOpacity: =>
        
        p = vec(0,4,0).rotate vec(0,0,1), 180-45-world.cageOpacityIndex*22.5
        @dot.position.copy p
        @render()

module.exports = CageButton
