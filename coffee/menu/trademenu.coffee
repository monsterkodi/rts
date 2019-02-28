###
000000000  00000000    0000000   0000000    00000000  00     00  00000000  000   000  000   000
   000     000   000  000   000  000   000  000       000   000  000       0000  000  000   000
   000     0000000    000000000  000   000  0000000   000000000  0000000   000 0 000  000   000
   000     000   000  000   000  000   000  000       000 0 000  000       000  0000  000   000
   000     000   000  000   000  0000000    00000000  000   000  00000000  000   000   0000000 
###

{ post, elem, $, log } = require 'kxk'

{ Bot } = require '../constants'

TradeButton  = require './tradebutton'
ToggleButton = require './togglebutton'
BotMenu      = require './botmenu'

class TradeMenu extends BotMenu

    constructor: (botButton) ->

        super botButton

        trade = rts.world.botOfType Bot.trade
        @addButton 'trade', new ToggleButton @div, @onTradeToggle, trade.state
        @addButton 'sell',  new TradeButton  @div, 'sell'
        @addButton 'buy',   new TradeButton  @div, 'buy'
        
    onTradeToggle: (tradeState) =>
        
        trade = rts.world.botOfType Bot.trade
        trade.state = tradeState
        post.emit 'botState', 'trade', tradeState
                    
module.exports = TradeMenu
