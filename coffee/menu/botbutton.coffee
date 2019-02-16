###
0000000     0000000   000000000        0000000    000   000  000000000  000000000   0000000   000   000
000   000  000   000     000           000   000  000   000     000        000     000   000  0000  000
0000000    000   000     000           0000000    000   000     000        000     000   000  000 0 000
000   000  000   000     000           000   000  000   000     000        000     000   000  000  0000
0000000     0000000      000           0000000     0000000      000        000      0000000   000   000
###

{ deg2rad, empty, elem, log, $, _ } = require 'kxk'

{ Stone, Bot } = require '../constants'

CanvasButton = require './canvasbutton'
BuyButton    = require './buybutton'
BaseMenu     = require './basemenu'
SubMenu      = require './submenu'
TradeMenu    = require './trademenu'
BuildMenu    = require './buildmenu'
BrainMenu    = require './brainmenu'
Materials    = require '../materials'

class BotButton extends CanvasButton

    constructor: (bot,div) ->

        super div
        
        @bot = bot
        @world = rts.world
        
        @name = "BotButton #{Bot.string @bot}"
        
        @canvas.id = @bot
        
        construct = @world.construct
        @mesh = new THREE.Mesh construct.botGeoms[construct.geomForBotType @bot], @botMat()
        @mesh.receiveShadow = true
        @mesh.castShadow = true
        @mesh.rotateZ deg2rad 45
        @scene.add @mesh
                
        switch @bot
            when Bot.mine
                @camera.position.copy vec(0,-1,0.6).normal().mul 1.1
                @camera.lookAt vec 0,0,0                
            when Bot.trade
                @camera.position.copy vec(0,-1,0.6).normal().mul 1.3
                @camera.lookAt vec 0,0,-0.1                
            when Bot.brain
                @camera.position.copy vec(0,-1,0.9).normal().mul 1.3
                @camera.lookAt vec 0,0,-0.05                
            else
                @camera.position.copy vec(0,-1,0.6).normal().mul 1.3
                @camera.lookAt vec 0,0,0
        
        @camera.updateProjectionMatrix()                
        @render()
        
    initScene: ->
        
        @scene.background = new THREE.Color 0x181818
        
        @light = new THREE.DirectionalLight 0xffffff
        @light.position.set -2,-2,2
        @scene.add @light
                
        @camera.near = 0.01
        @camera.far = 10
        @camera.fov = 30
        
    focusNextBot: ->
        
        bots = @world.botsOfType @bot
        index = (bots.indexOf(@focusBot)+1) % bots.length
        @focusBot = bots[index]
        if @focusBot
            @world.highlightBot @focusBot
            rts.camera.focusOnPos @focusBot.pos
        
    click: -> @focusNextBot()
    
    show: (clss) ->
        
        BotButton.currentlyShown?.del()
        BotButton.currentlyShown = new clss @ 
    
    highlight: ->

        SubMenu.close()
        
        if @bot == Bot.mine or not @world.botOfType @bot
            @show BuyButton
        else 
            switch @bot
                when Bot.base  then @show BaseMenu  
                when Bot.trade then @show TradeMenu
                when Bot.build then @show BuildMenu
                when Bot.brain then @show BrainMenu
            
        @camera.fov = 28
        @camera.updateProjectionMatrix()
        @mesh.material = @botMat true
        @render()
        
    unhighlight: ->
        
        @camera.fov = 30
        @camera.updateProjectionMatrix()
        @mesh.material = @botMat false
        @render()
        
    update: ->
        
        @mesh.material = @botMat false
        @render()
        
    botMat: (highlight=false) ->
        
        if empty @world.botsOfType @bot
            if highlight then Materials.menu.inactiveHigh else Materials.menu.inactive
        else
            if highlight then Materials.menu.activeHigh else Materials.menu.active
        
module.exports = BotButton
