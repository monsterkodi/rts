###
0000000    000   000  000000000  000000000   0000000   000   000
000   000  000   000     000        000     000   000  0000  000
0000000    000   000     000        000     000   000  000 0 000
000   000  000   000     000        000     000   000  000  0000
0000000     0000000      000        000      0000000   000   000
###

{ deg2rad, elem, log, $, _ } = require 'kxk'

{ Stone, Bot } = require './constants'

Materials = require './materials'

class Button

    constructor: (@bot,x,y) ->

        @width  = 100
        @height = 100
        
        @canvas = elem 'canvas', class:'buttonCanvas', width:@width, height:@height, style:"left:#{x}px; top:#{y}px"
        $("#main").appendChild @canvas
        
        @renderer = new THREE.WebGLRenderer antialias:true, canvas:@canvas
        @renderer.setPixelRatio window.devicePixelRatio
        @renderer.setSize @width, @height
        
        @scene = new THREE.Scene()
        @scene.background = new THREE.Color 0x181818
        
        @light = new THREE.DirectionalLight 0xffffff
        @light.position.set -2,-2,2
        @scene.add @light
        
        construct = rts.world.construct
        mat = new THREE.MeshStandardMaterial color:0xcccccc, metalness: 0.9, roughness: 0.75
        @mesh = new THREE.Mesh construct.botGeoms[construct.geomForBotType @bot], mat
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
        
module.exports = Button
