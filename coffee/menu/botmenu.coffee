###
0000000     0000000   000000000  00     00  00000000  000   000  000   000
000   000  000   000     000     000   000  000       0000  000  000   000
0000000    000   000     000     000000000  0000000   000 0 000  000   000
000   000  000   000     000     000 0 000  000       000  0000  000   000
0000000     0000000      000     000   000  00000000  000   000   0000000 
###

{ elem } = require 'kxk'

class BotMenu

    constructor: (@botButton) ->

        y = @botButton.canvas.offsetTop - rts.menuBorderWidth
        @div = elem class:'botMenu', style:"left:100px; top:#{y}px"
        
        @botButton.canvas.parentElement.appendChild @div
        
        @buttons = {}
                
    addButton: (key, button) ->
        
        @buttons[key] = button
        @div.style.width = "#{Object.values(@buttons).length*100}px"
        
    del: ->
        
        for key,button of @buttons
            button.del()
            
        @div.remove()

module.exports = BotMenu
