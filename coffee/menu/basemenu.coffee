###
0000000     0000000    0000000  00000000  00     00  00000000  000   000  000   000
000   000  000   000  000       000       000   000  000       0000  000  000   000
0000000    000000000  0000000   0000000   000000000  0000000   000 0 000  000   000
000   000  000   000       000  000       000 0 000  000       000  0000  000   000
0000000    000   000  0000000   00000000  000   000  00000000  000   000   0000000 
###

{ post, state } = require 'kxk'

BotMenu      = require './botmenu'
ToggleButton = require './togglebutton'

class BaseMenu extends BotMenu

    constructor: (botButton) -> 
    
        super botButton
        
        btn = @addButton 'pause', new ToggleButton @div, @onBaseToggle, rts.paused and 'off' or 'on'
        
        post.on 'pause', => @buttons.pause.setState rts.paused and 'off' or 'on'
                
    addButton: (key, button) -> @buttons[key] = button
        
    onBaseToggle: (baseState) => rts.togglePause()

module.exports = BaseMenu
