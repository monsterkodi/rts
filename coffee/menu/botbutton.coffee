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
Materials    = require '../materials'

class BotButton extends CanvasButton

    constructor: (bot,div) ->

        super div
        
        @bot = bot
        @world = rts.world
        
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
    
    highlight: ->
        
        BuyButton.button?.del()
        BuyButton.button = new BuyButton @ if @bot != Bot.base
        @camera.fov = 28
        @camera.updateProjectionMatrix()
        @mesh.material = @botMat true
        @render()
        
    unhighlight: ->
        
        @camera.fov = 30
        @camera.updateProjectionMatrix()
        @mesh.material = @botMat false
        @render()
        
    botMat: (highlight=false) ->
        
        if empty @world.botsOfType @bot
            color = highlight and 0x555555 or 0x333333
        else
            color = highlight and 0xffffff or 0xcccccc
        
        mat = new THREE.MeshStandardMaterial color:color, metalness: 0.9, roughness: 0.75
        
module.exports = BotButton
