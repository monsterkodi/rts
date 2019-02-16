###
0000000    00000000    0000000   000  000   000  00     00  00000000  000   000  000   000
000   000  000   000  000   000  000  0000  000  000   000  000       0000  000  000   000
0000000    0000000    000000000  000  000 0 000  000000000  0000000   000 0 000  000   000
000   000  000   000  000   000  000  000  0000  000 0 000  000       000  0000  000   000
0000000    000   000  000   000  000  000   000  000   000  00000000  000   000   0000000 
###

{ log } = require 'kxk'

BrainButton  = require './brainbutton'
ToggleButton = require './togglebutton'
Science = require '../science'
BotMenu = require './botmenu'

class BrainMenu extends BotMenu

    constructor: (botButton) -> 
    
        super botButton
        
        @div.style.borderBottom = 'unset'
        
        border = "#{rts.menuBorderWidth}px transparent"
        
        btn = @addButton 'brain', new ToggleButton @div, @onBrainToggle, state.brain.state
        btn.canvas.style.borderBottom = border
                
        for science,cfg of Science.tree
            for key,values of cfg
                
                scienceKey = science + '.' + key
                btn = @addButton scienceKey, new BrainButton @div, scienceKey
                
                btn.canvas.style.left = "#{values.x*100+100}px"
                btn.canvas.style.top  = "#{values.y*100}px"
                
                if values.x == 1 and values.y
                    btn.canvas.style.borderLeft = border
                if values.y == 3
                    btn.canvas.style.borderBottom = border
                
        @div.style.width  = "400px"
        @div.style.height = "400px"
                
    addButton: (key, button) -> @buttons[key] = button
        
    onBrainToggle: (brainState) => state.brain.state = brainState
                
module.exports = BrainMenu
