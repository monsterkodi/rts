###
000000000  00000000    0000000   0000000    00000000  0000000    000   000  000000000  000000000   0000000   000   000
   000     000   000  000   000  000   000  000       000   000  000   000     000        000     000   000  0000  000
   000     0000000    000000000  000   000  0000000   0000000    000   000     000        000     000   000  000 0 000
   000     000   000  000   000  000   000  000       000   000  000   000     000        000     000   000  000  0000
   000     000   000  000   000  0000000    00000000  0000000     0000000      000        000      0000000   000   000
###

{ post, log, _ } = require 'kxk'

{ Stone, Bot } = require '../constants'

SubMenu     = require './submenu'
StoneMenu   = require './stonemenu'
StoneButton = require './stonebutton'
Materials   = require '../materials'

class TradeButton extends StoneButton

    TradeButton.sell = null
    TradeButton.buy  = null
    
    constructor: (div, inOut) ->
        
        stone = state.trade[inOut]
        
        super div, stone, inOut, 'tradeButton canvasButtonInline'
        
        @name = "TradeButton #{inOut}"
        
        TradeButton[@inOut] = @
        
        post.on @inOut, @onTrade
        post.on 'scienceFinished', @onScienceFinished
        
    del: ->

        post.removeListener @inOut, @onTrade 
        post.removeListener 'scienceFinished', @onScienceFinished
        super()
                
    onScienceFinished: (scienceKey) =>
        
        if scienceKey == 'trade.sell' and @inOut == 'sell'
            if SubMenu.current?.button == @
                new StoneMenu @
            @render()
        
    onTrade: (stone) =>
        
        @stone = stone
        state.trade[@inOut] = @stone
        new StoneMenu @
        @render()
        
    highlight: -> 

        new StoneMenu @
        super()
        
    click: -> 
        
module.exports = TradeButton
