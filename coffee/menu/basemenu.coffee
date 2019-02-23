###
0000000     0000000    0000000  00000000  00     00  00000000  000   000  000   000
000   000  000   000  000       000       000   000  000       0000  000  000   000
0000000    000000000  0000000   0000000   000000000  0000000   000 0 000  000   000
000   000  000   000       000  000       000 0 000  000       000  0000  000   000
0000000    000   000  0000000   00000000  000   000  00000000  000   000   0000000 
###

{ log } = require 'kxk'

BotMenu      = require './botmenu'
CallButton   = require './callbutton'
ToggleButton = require './togglebutton'

class BaseMenu extends BotMenu

    constructor: (botButton) -> 
    
        super botButton
        
        # btn = @addButton 'pause', new ToggleButton @div, @onBaseToggle, rts.paused and 'off' or 'on'
        # post.on 'pause', => @buttons.pause.setState rts.paused and 'off' or 'on'
        @addButton 'state', new ToggleButton @div, @onBaseToggle, state.base.state
        @addButton 'call',  new CallButton @div
                
    addButton: (key, button) -> @buttons[key] = button
        
    onBaseToggle: (baseState) => state.base.state = baseState

module.exports = BaseMenu
