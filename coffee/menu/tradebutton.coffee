###
000000000  00000000    0000000   0000000    00000000  0000000    000   000  000000000  000000000   0000000   000   000
   000     000   000  000   000  000   000  000       000   000  000   000     000        000     000   000  0000  000
   000     0000000    000000000  000   000  0000000   0000000    000   000     000        000     000   000  000 0 000
   000     000   000  000   000  000   000  000       000   000  000   000     000        000     000   000  000  0000
   000     000   000  000   000  0000000    00000000  0000000     0000000      000        000      0000000   000   000
###

{ post, log, _ } = require 'kxk'

{ Stone, Bot } = require '../constants'

StoneMenu   = require './stonemenu'
StoneButton = require './stonebutton'
Materials   = require '../materials'

class TradeButton extends StoneButton

    TradeButton.sell = null
    TradeButton.buy  = null
    
    constructor: (div, inOut) ->
        
        stone = rts.world.status.trade[inOut]
        
        super div, stone, inOut, 'tradeButton buttonCanvasInline'
        
        @name = "TradeButton #{inOut}"
        
        TradeButton[@inOut] = @
        
        post.on @inOut, @onTrade
        
    del: ->

        post.removeListener @inOut, @onTrade 
        super()
        
    onTrade: (stone) =>
        
        @stone = stone
        rts.world.status.trade[@inOut] = @stone
        new StoneMenu @
        @render()
        
    highlight: -> 

        new StoneMenu @
        super()
        
    click: -> 
        
module.exports = TradeButton
