###
0000000     0000000    0000000  00000000  00     00  00000000  000   000  000   000
000   000  000   000  000       000       000   000  000       0000  000  000   000
0000000    000000000  0000000   0000000   000000000  0000000   000 0 000  000   000
000   000  000   000       000  000       000 0 000  000       000  0000  000   000
0000000    000   000  0000000   00000000  000   000  00000000  000   000   0000000 
###

{ post, log } = require 'kxk'

BotMenu      = require './botmenu'
CallButton   = require './callbutton'
ToggleButton = require './togglebutton'

class BaseMenu extends BotMenu

    constructor: (botButton) -> 
    
        super botButton
        
        @addButton 'state', new ToggleButton @div, @onBaseToggle, rts.world.bases[0].state
        @addButton 'call',  new CallButton @div
                
    onBaseToggle: (baseState) => 
    
        rts.world.bases[0].state = baseState
        post.emit 'botState', 'base', baseState

module.exports = BaseMenu
