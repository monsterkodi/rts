###
00     00  00000000  000   000  000   000
000   000  000       0000  000  000   000
000000000  0000000   000 0 000  000   000
000 0 000  000       000  0000  000   000
000   000  00000000  000   000   0000000 
###

{ elem, log, $, _ } = require 'kxk'

{ Bot } = require './constants'

Storage = require './storage'
Button = require './button'

class Menu

    constructor: ->

        @div = elem class:'buttons', style:"left:0px; top:0px"
        $("#main").appendChild @div
        
        rts.world.storage = new Storage @
        
        @buttons = [rts.world.storage]
                
        for bot in Bot.values
            @buttons.push new Button bot, @div
            
        @div.addEventListener 'mouseenter', @onMouseEnter
        @div.addEventListener 'mouseleave', @onMouseLeave
        @div.addEventListener 'mouseout',   @onMouseOut

    onMouseLeave: => #log 'onMouseLeave'
    onMouseOut: => #log 'onMouseOut'
    onMouseEnter: (event) => 
        log event
        button = @buttonForEvent event
        log 'onMouseEnter', button?
        button?.highlight?()
        
    buttonForEvent: (event) ->
        
        for button in @buttons
            if (event.target == button.canvas)
                return button
        
module.exports = Menu
