###
 0000000  000000000   0000000   000   000  00000000  00     00  00000000  000   000  000   000
000          000     000   000  0000  000  000       000   000  000       0000  000  000   000
0000000      000     000   000  000 0 000  0000000   000000000  0000000   000 0 000  000   000
     000     000     000   000  000  0000  000       000 0 000  000       000  0000  000   000
0000000      000      0000000   000   000  00000000  000   000  00000000  000   000   0000000 
###

{ log, _ } = require 'kxk'

{ Stone }   = require '../constants'
StoneButton = require './stonebutton'
SubMenu     = require './submenu'

class StoneMenu extends SubMenu

    constructor: (tradeButton) ->

        super tradeButton

        filter = (s) -> 
        
            return false if s == tradeButton.stone
            other = if tradeButton.inOut == 'sell' then 'buy' else 'sell'
            TradeButton = require './tradebutton'
            TradeButton[other].stone != s
        
        for stone in Stone.resources.filter filter
            
            @addButton Stone.toString(stone), new StoneButton @div, stone, tradeButton.inOut

module.exports = StoneMenu
