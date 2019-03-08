###
0000000     0000000   000000000  00     00  00000000  000   000  000   000
000   000  000   000     000     000   000  000       0000  000  000   000
0000000    000   000     000     000000000  0000000   000 0 000  000   000
000   000  000   000     000     000 0 000  000       000  0000  000   000
0000000     0000000      000     000   000  00000000  000   000   0000000 
###

class BotMenu

    constructor: (@botButton) ->

        y = @botButton.canvas.offsetTop - rts.menuBorderWidth
        @div = elem class:'botMenu', style:"left:100px; top:#{y}px; width:100px;"
        
        @botButton.canvas.parentElement.appendChild @div
        
        @buttons = {}
                
    addButton: (key, button) ->
        
        @buttons[key] = button
        button
        
    animate: (delta) ->
        
        for key,button of @buttons
            button.animate delta
            
    update: ->
        
        for key,button of @buttons
            button.update()
        
    del: ->
        
        for key,button of @buttons
            button.del()
            
        @div.remove()

module.exports = BotMenu
