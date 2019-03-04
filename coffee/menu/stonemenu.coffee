###
 0000000  000000000   0000000   000   000  00000000  00     00  00000000  000   000  000   000
000          000     000   000  0000  000  000       000   000  000       0000  000  000   000
0000000      000     000   000  000 0 000  0000000   000000000  0000000   000 0 000  000   000
     000     000     000   000  000  0000  000       000 0 000  000       000  0000  000   000
0000000      000      0000000   000   000  00000000  000   000  00000000  000   000   0000000 
###

StoneButton = require './stonebutton'
SubMenu     = require './submenu'

class StoneMenu extends SubMenu

    constructor: (tradeButton) ->

        super tradeButton

        filter = (s) -> s != tradeButton.stone
        
        for stone in Stone.resources.filter filter
            
            @addButton Stone.string(stone), new StoneButton @div, stone, tradeButton.inOut

module.exports = StoneMenu
