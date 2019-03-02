###
00     00  00000000  000   000  000   000
000   000  000       0000  000  000   000
000000000  0000000   000 0 000  000   000
000 0 000  000       000  0000  000   000
000   000  00000000  000   000   0000000 
###

{ post, stopEvent, elem, log, $, _ } = require 'kxk'

{ Bot }   = require '../constants'

Color         = require '../color'
StorageButton = require './storagebutton'
BotButton     = require './botbutton'
BuyButton     = require './buybutton'
SpeedButton   = require './speedbutton'
SubMenu       = require './submenu'

class Menu

    constructor: ->

        main =$ "#main"
        @div = elem class:'buttons', style:"left:0px; top:0px"
        main.appendChild @div
        
        @buttons = storage:new StorageButton @
         
        bots = [
            Bot.base
            Bot.brain
            Bot.trade
            Bot.berta
            Bot.mine
            Bot.build
        ]
        
        for bot in bots
            @buttons[Bot.string bot] = new BotButton bot, @div
            
        @speed = new SpeedButton main
            
        @div.addEventListener 'mouseenter', @onMouseEnter
        @div.addEventListener 'mouseleave', @onMouseLeave
        @div.addEventListener 'mouseover',  @onMouseOver
        @div.addEventListener 'mouseout',   @onMouseOut
        @div.addEventListener 'mousemove',  @onMouseMove
        @div.addEventListener 'click',      @onClick
                
        post.on 'botCreated', @onBotCreated
        
    onBotCreated: (bot) => 
        
        @buttons[Bot.string bot.type].update()
        @buttons[Bot.string bot.type].highlight()
        
    onClick:      (event) => event.target.button?.click? event
    onMouseOver:  (event) => event.target.button?.highlight? event
    onMouseOut:   (event) => event.target.button?.unhighlight? event
    onMouseMove:  (event) => stopEvent event
    onMouseEnter: (event) =>

        for key,button of @buttons
            button.scene.background = Color.menu.backgroundHover
            button.render()
        
    onMouseLeave: (event) => 
        
        BotButton.currentlyShown?.del()
        delete BotButton.currentlyShown
           
        SubMenu.close()
         
        for key,button of @buttons
            button.scene.background = Color.menu.background
            button.render()                
        
    animate: (delta) ->
        
        @buttons.storage.animate delta
            
module.exports = Menu
