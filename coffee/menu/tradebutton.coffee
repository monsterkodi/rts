###
000000000  00000000    0000000   0000000    00000000  0000000    000   000  000000000  000000000   0000000   000   000
   000     000   000  000   000  000   000  000       000   000  000   000     000        000     000   000  0000  000
   000     0000000    000000000  000   000  0000000   0000000    000   000     000        000     000   000  000 0 000
   000     000   000  000   000  000   000  000       000   000  000   000     000        000     000   000  000  0000
   000     000   000  000   000  0000000    00000000  0000000     0000000      000        000      0000000   000   000
###

SubMenu     = require './submenu'
StoneMenu   = require './stonemenu'
StoneButton = require './stonebutton'

class TradeButton extends StoneButton

    TradeButton.sell = null
    TradeButton.buy  = null
    
    constructor: (div, inOut) ->
        
        trade = rts.world.botOfType Bot.trade
        stone = trade[inOut]
        
        super div, stone, inOut, 'tradeButton canvasButtonInline'
        
        @name = "TradeButton #{inOut}"
        
        TradeButton[@inOut] = @
        
        post.on @inOut, @onTrade
        post.on 'scienceFinished', @onScienceFinished
        
    del: ->

        post.removeListener @inOut, @onTrade 
        post.removeListener 'scienceFinished', @onScienceFinished
        super()
                
    onScienceFinished: (info) =>
        
        if info.scienceKey == 'trade.sell' and @inOut == 'sell'
            if SubMenu.current?.button == @
                new StoneMenu @
            @render()
        
    onTrade: (stone) =>
        log "onTrade #{@inOut} #{Stone.string stone}"
        @stone = stone
        trade = rts.world.botOfType Bot.trade
        trade[@inOut] = @stone
        
        other = if @inOut == 'sell' then 'buy' else 'sell'
        if trade[other] == @stone
            post.emit other, first Stone.resources.filter (s) => s != @stone
        
        new StoneMenu @
        @render()
        
    highlight: -> 

        new StoneMenu @
        super()
        
    click: -> 
        
module.exports = TradeButton
