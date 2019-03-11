###
00     00  00000000  000   000  000   000
000   000  000       0000  000  000   000
000000000  0000000   000 0 000  000   000
000 0 000  000       000  0000  000   000
000   000  00000000  000   000   0000000
###

StorageButton = require './storagebutton'
BotButton     = require './botbutton'
BuyButton     = require './buybutton'
SpeedButton   = require './speedbutton'
OpacityButton = require './opacitybutton'
VolumeButton  = require './volumebutton'

class Menu

    constructor: ->

        main =$ "#main"
        @div = elem class:'buttons', style:"left:0px; top:0px"
        main.appendChild @div

        @mousePos = vec()
        @botButtons = {}
        @buttons =
            storage: new StorageButton @
            speed:   new SpeedButton   main
            opacity: new OpacityButton main
            volume:  new VolumeButton  main

        bots = [
            Bot.base
            Bot.brain
            Bot.trade
            Bot.build
            Bot.berta
            Bot.mine
        ]

        for bot in bots
            botButton = new BotButton bot, @div
            @buttons[Bot.string bot] = botButton
            @botButtons[Bot.string bot] = botButton
            botButton.scene.background = Color.menu.background

        @buttons.storage.scene.background = Color.menu.background

        @div.addEventListener 'mouseenter', @onMouseEnter
        @div.addEventListener 'mouseleave', @onMouseLeave
        @div.addEventListener 'mousemove',  @onMouseMove
        main.addEventListener 'mouseover',  @onMouseOver
        main.addEventListener 'mouseout',   @onMouseOut
        main.addEventListener 'mousedown',  @onMouseDown
        main.addEventListener 'click',      @onClick

        post.on 'botCreated', @onBotCreated
        post.on 'botRemoved', @onBotRemoved
        post.on 'botDamaged', @onBotDamaged
        post.on 'world',      @onWorld
        
        @onWorld rts.world
        
    onWorld: (world) =>
        
        @div.style.display = if world.isMeta then 'none' else 'block'

    onBotRemoved: (type, player) =>

        if player == 0 and type != Bot.icon
            @buttons[Bot.string type].update()
            if @buttons.bot?.botButton == @buttons[Bot.string type]
                @buttons[Bot.string type].highlight()

    onBotDamaged: (bot) =>

        if bot.player == 0
            @buttons[Bot.string bot.type].update()

    onBotCreated: (bot) =>

        @buttons[Bot.string bot.type].update()
        if @buttons.bot?.botButton == @buttons[Bot.string bot.type]
            @buttons.bot.del()
            delete @buttons.bot
            @buttons[Bot.string bot.type].highlight()

    onClick:      (event) => @calcMouse event ; event.target.button?.click? event
    onMouseOver:  (event) => @calcMouse event ; event.target.button?.highlight? event
    onMouseOut:   (event) => @calcMouse event ; event.target.button?.unhighlight? event
    onMouseDown:  (event) =>

        @calcMouse event
        event.target.button?.middleClick?(event) if event.button == 1
        event.target.button?.rightClick?(event) if event.button == 2

    onMouseEnter: (event) =>

        for key,button of @botButtons
            button.scene.background = Color.menu.backgroundHover
            button.update()

        @buttons.storage.scene.background = Color.menu.backgroundHover
        @buttons.storage.update()

    onMouseMove:  (event) =>

        @calcMouse event
        stopEvent event

    onMouseLeave: (event) =>

        @calcMouse event
        @buttons.bot?.del()
        delete @buttons.bot

        for key,button of @botButtons
            button.scene.background = Color.menu.background
            button.update()

        @buttons.storage.scene.background = Color.menu.background
        @buttons.storage.update()

    calcMouse: (event) ->

        br = @div.getBoundingClientRect()
        @mousePos.x = event.clientX-br.left
        @mousePos.y = event.clientY-br.top

    animate: (delta) ->

        for key,button of @buttons
            # log key, button.name
            button.animate delta

module.exports = Menu
