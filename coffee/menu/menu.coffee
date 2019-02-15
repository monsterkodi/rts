###
00     00  00000000  000   000  000   000
000   000  000       0000  000  000   000
000000000  0000000   000 0 000  000   000
000 0 000  000       000  0000  000   000
000   000  00000000  000   000   0000000 
###

{ post, stopEvent, elem, log, $, _ } = require 'kxk'

{ Bot }   = require '../constants'

Storage   = require '../storage'
BotButton = require './botbutton'
BuyButton = require './buybutton'
SubMenu   = require './submenu'

class Menu

    constructor: ->

        @div = elem class:'buttons', style:"left:0px; top:0px"
        $("#main").appendChild @div
        
        rts.world.storage = new Storage @
        
        @buttons = storage:rts.world.storage
         
        bots = [
            Bot.base
            Bot.brain
            Bot.trade
            Bot.build
            Bot.mine
        ]
        
        for bot in bots
            @buttons[Bot.string bot] = new BotButton bot, @div
            
        @div.addEventListener 'mouseleave', @onMouseLeave
        @div.addEventListener 'mouseover',  @onMouseOver
        @div.addEventListener 'mouseout',   @onMouseOut
        @div.addEventListener 'mousemove',  @onMouseMove
        @div.addEventListener 'click',      @onClick
        
        post.on 'botCreated', @onBotCreated
        
    onBotCreated: (bot) => 
        
        # log "menu.onBotCreated #{Bot.string bot.type}"
        @buttons[Bot.string bot.type].update()
        @buttons[Bot.string bot.type].highlight()
        
    onClick:      (event) => event.target.button?.click?()
    onMouseOver:  (event) => event.target.button?.highlight?()
    onMouseOut:   (event) => event.target.button?.unhighlight?()
    onMouseMove:  (event) => stopEvent event
    onMouseLeave: (event) => 
        
        BotButton.currentlyShown?.del()
        delete BotButton.currentlyShown
         
        SubMenu.close()
        
module.exports = Menu
