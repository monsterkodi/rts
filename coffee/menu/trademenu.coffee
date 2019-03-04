###
000000000  00000000    0000000   0000000    00000000  00     00  00000000  000   000  000   000
   000     000   000  000   000  000   000  000       000   000  000       0000  000  000   000
   000     0000000    000000000  000   000  0000000   000000000  0000000   000 0 000  000   000
   000     000   000  000   000  000   000  000       000 0 000  000       000  0000  000   000
   000     000   000  000   000  0000000    00000000  000   000  00000000  000   000   0000000 
###

TradeButton  = require './tradebutton'
BotMenu      = require './botmenu'

class TradeMenu extends BotMenu

    constructor: (botButton) ->

        super botButton

        trade = rts.world.botOfType Bot.trade
        @addButton 'sell',  new TradeButton  @div, 'sell'
        @addButton 'buy',   new TradeButton  @div, 'buy'
        
module.exports = TradeMenu
