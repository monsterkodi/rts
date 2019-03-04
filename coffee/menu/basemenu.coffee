###
0000000     0000000    0000000  00000000  00     00  00000000  000   000  000   000
000   000  000   000  000       000       000   000  000       0000  000  000   000
0000000    000000000  0000000   0000000   000000000  0000000   000 0 000  000   000
000   000  000   000       000  000       000 0 000  000       000  0000  000   000
0000000    000   000  0000000   00000000  000   000  00000000  000   000   0000000 
###

BotMenu      = require './botmenu'
CallButton   = require './callbutton'

class BaseMenu extends BotMenu

    constructor: (botButton) -> 
    
        super botButton
        
        @addButton 'call', new CallButton @div
                
module.exports = BaseMenu
