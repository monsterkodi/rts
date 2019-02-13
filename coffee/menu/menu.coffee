###
00     00  00000000  000   000  000   000
000   000  000       0000  000  000   000
000000000  0000000   000 0 000  000   000
000 0 000  000       000  0000  000   000
000   000  00000000  000   000   0000000 
###

{ post, elem, log, $, _ } = require 'kxk'

{ Bot }   = require '../constants'

Storage   = require '../storage'
BotButton = require './botbutton'
BuyButton = require './buybutton'

class Menu

    constructor: ->

        @div = elem class:'buttons', style:"left:0px; top:0px"
        $("#main").appendChild @div
        
        rts.world.storage = new Storage @
        
        @buttons = storage:rts.world.storage
                
        for bot in Bot.values
            @buttons[Bot.string bot] = new BotButton bot, @div
            
        @div.addEventListener 'mouseleave', @onMouseLeave
        @div.addEventListener 'mouseover',  @onMouseOver
        @div.addEventListener 'mouseout',   @onMouseOut
        @div.addEventListener 'click',      @onClick
        
        post.on 'botCreated', @onBotCreated
        
    onBotCreated: (bot) => 
        
        log "menu.onBotCreated #{Bot.string bot.type}"
        @buttons[Bot.string bot.type].update()
        
    onClick:      (event) => @buttonForEvent(event)?.click()
    onMouseOver:  (event) => @buttonForEvent(event)?.highlight?()
    onMouseOut:   (event) => @buttonForEvent(event)?.unhighlight?()
    onMouseLeave: (event) => BuyButton.button?.del()
        
    buttonForEvent: (event) ->
        
        for key,button of @buttons
            if event.target == button.canvas
                return button
                
        if event.target == BuyButton.button?.canvas
            return BuyButton.button
        
module.exports = Menu
