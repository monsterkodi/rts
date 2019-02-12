###
0000000     0000000   000000000        0000000    000   000  000000000  000000000   0000000   000   000
000   000  000   000     000           000   000  000   000     000        000     000   000  0000  000
0000000    000   000     000           0000000    000   000     000        000     000   000  000 0 000
000   000  000   000     000           000   000  000   000     000        000     000   000  000  0000
0000000     0000000      000           0000000     0000000      000        000      0000000   000   000
###

{ deg2rad, empty, elem, log, $, _ } = require 'kxk'

{ Stone, Bot } = require '../constants'

BuyButton = require './buybutton'
Materials = require '../materials'

class BotButton

    constructor: (@bot,div) ->

        @world = rts.world
        
        @width  = 100
        @height = 100
        
        @canvas = elem 'canvas', class:'buttonCanvas', width:@width, height:@height, id:@bot
        div.appendChild @canvas
        
        @renderer = new THREE.WebGLRenderer antialias:true, canvas:@canvas
        @renderer.setPixelRatio window.devicePixelRatio
        @renderer.setSize @width, @height
        
        @scene = new THREE.Scene()
        @scene.background = new THREE.Color 0x181818
        
        @light = new THREE.DirectionalLight 0xffffff
        @light.position.set -2,-2,2
        @scene.add @light
        
        construct = @world.construct
        
        @mesh = new THREE.Mesh construct.botGeoms[construct.geomForBotType @bot], @botMat()
        @mesh.receiveShadow = true
        @mesh.castShadow = true
        @mesh.rotateZ deg2rad 45
        @scene.add @mesh
        
        @camera = new THREE.PerspectiveCamera 30, @width/@height, 0.01, 10
        switch @bot
            when Bot.mine
                @camera.position.copy vec(0,-1,0.6).normal().mul 1.1
                @camera.lookAt vec 0,0,0                
            when Bot.trade
                @camera.position.copy vec(0,-1,0.6).normal().mul 1.3
                @camera.lookAt vec 0,0,-0.1                
            when Bot.science
                @camera.position.copy vec(0,-1,0.9).normal().mul 1.3
                @camera.lookAt vec 0,0,-0.05                
            else
                @camera.position.copy vec(0,-1,0.6).normal().mul 1.3
                @camera.lookAt vec 0,0,0
        
        @renderer.render @scene, @camera

    focusNextBot: ->
        
        bots = @world.botsOfType @bot
        index = (bots.indexOf(@focusBot)+1) % bots.length
        @focusBot = bots[index]
        if @focusBot
            @world.highlightBot @focusBot
            rts.camera.focusOnPos @focusBot.pos
        
    click: -> @focusNextBot()
    
    highlight: ->
        
        # new BuyButton @
        @camera.fov = 28
        @camera.updateProjectionMatrix()
        @mesh.material = @botMat true
        @renderer.render @scene, @camera
        
    unhighlight: ->
        
        @camera.fov = 30
        @camera.updateProjectionMatrix()
        @mesh.material = @botMat false
        @renderer.render @scene, @camera
        
    botMat: (highlight=false) ->
        
        if empty @world.botsOfType @bot
            color = highlight and 0x555555 or 0x333333
        else
            color = highlight and 0xffffff or 0xcccccc
        
        mat = new THREE.MeshStandardMaterial color:color, metalness: 0.9, roughness: 0.75
        
module.exports = BotButton
