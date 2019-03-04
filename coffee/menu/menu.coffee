###
00     00  00000000  000   000  000   000
000   000  000       0000  000  000   000
000000000  0000000   000 0 000  000   000
000 0 000  000       000  0000  000   000
000   000  00000000  000   000   0000000 
###

{ stopEvent } = require 'kxk'

StorageButton = require './storagebutton'
BotButton     = require './botbutton'
BuyButton     = require './buybutton'
SpeedButton   = require './speedbutton'
OpacityButton = require './opacitybutton'
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
            
        new SpeedButton main
        new OpacityButton main
            
        @div.addEventListener 'mouseenter', @onMouseEnter
        @div.addEventListener 'mouseleave', @onMouseLeave
        @div.addEventListener 'mouseover',  @onMouseOver
        @div.addEventListener 'mouseout',   @onMouseOut
        @div.addEventListener 'mousemove',  @onMouseMove
        @div.addEventListener 'click',      @onClick
                
        post.on 'botCreated', @onBotCreated
        post.on 'botRemoved', @onBotRemoved

    onBotRemoved: (type, player) =>
        if player == 0
            @buttons[Bot.string type].update()
            if BotButton.currentlyShown?.botButton == @buttons[Bot.string type]
                @buttons[Bot.string type].highlight()
        
    onBotCreated: (bot) => 
        # log "onBotCreated #{Bot.string bot.type}", SubMenu.current?, BotButton.currentlyShown?.botButton == @buttons[Bot.string bot.type]
        @buttons[Bot.string bot.type].update()
        if BotButton.currentlyShown?.botButton == @buttons[Bot.string bot.type]
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
