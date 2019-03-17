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

    constructor: (@botButton) ->

        super @botButton

        @name = 'TradeMenu'
        
    initButtons: ->
        
        @div.style.width  = "200px"
        @div.style.height = "400px"

        btn = @addButton 'sell', new TradeButton  @, 'sell'
        btn = @addButton 'buy',  new TradeButton  @, 'buy'
        btn.canvas.style.left = "100px"
        
    buttonClicked: (button) ->
        
        trade = world.botOfType Bot.trade
        trade[button.inOut] = button.stone
        
        @buttons[button.inOut].stone = button.stone
        for i in [0...3]
            key = "#{button.inOut}#{i}"
        
        other = if button.inOut == 'sell' then 'buy' else 'sell'
        
        if trade[other] == button.stone
            otherStone = first Stone.resources.filter (s) -> s != button.stone
            trade[other] = otherStone
            @buttons[other].stone = otherStone
            @updateStones @buttons[other]
            
        @updateStones button
        @botButton.update()
        @update()
        
    highlight: (button) ->
        
        return if button != @buttons[button.inOut]
        return if @buttons["#{button.inOut}0"]?
               
        other = if button.inOut == 'sell' then 'buy' else 'sell'
        
        for i in [0...3]

            @buttons["#{other}#{i}"]?.del()
            delete @buttons["#{other}#{i}"]
            
            btn = @addButton "#{button.inOut}#{i}", new TradeButton @, button.inOut, Stone.gray
            
            left = if button.inOut == 'sell' then 0 else 100
            top  = (i+1)*100
            
            btn.canvas.style.left = "#{left}px"
            btn.canvas.style.top  = "#{top}px"
            
        @updateStones button
            
    unhighlight: (button) ->
        
        if button.inOut == 'buy' and rts.menu.mousePos.x < 200
            @highlight @buttons.sell
        else if button.inOut == 'sell' and rts.menu.mousePos.x >= 200
            @highlight @buttons.buy
        
    updateStones: (button) ->
        
        stones = Stone.resources.filter (s) -> s != button.stone
        for i in [0...3]
            @buttons["#{button.inOut}#{i}"]?.stone = stones[i]
            
module.exports = TradeMenu
