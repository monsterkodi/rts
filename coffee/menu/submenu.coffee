###
 0000000  000   000  0000000    00     00  00000000  000   000  000   000
000       000   000  000   000  000   000  000       0000  000  000   000
0000000   000   000  0000000    000000000  0000000   000 0 000  000   000
     000  000   000  000   000  000 0 000  000       000  0000  000   000
0000000    0000000   0000000    000   000  00000000  000   000   0000000 
###

{ elem, log, _ } = require 'kxk'

class SubMenu

    @current = null
    
    constructor: (@button) ->

        SubMenu.current?.del()
        
        x = @button.canvas.parentElement.offsetLeft + @button.canvas.offsetLeft - rts.menuBorderWidth
        y = @button.canvas.parentElement.offsetTop + 100 + rts.menuBorderWidth
            
        @div = elem class:'subMenu', style:"left:#{x}px; top:#{y}px;"
        
        @button.canvas.parentElement.parentElement.appendChild @div
                
        @buttons = {}
        
        SubMenu.current = @

    @close: ->
        
        SubMenu.current?.del()
        delete SubMenu.current
                
    addButton: (key, button) ->
        
        @buttons[key] = button
        
        @div.style.height = "#{Object.keys(@buttons).length*100}px"
        
    del: ->

        for key,button of @buttons
            button.del()
            
        @div.remove()

module.exports = SubMenu
