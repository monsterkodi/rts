###
000000000  00000000    0000000   0000000    00000000  0000000    000   000  000000000  000000000   0000000   000   000
   000     000   000  000   000  000   000  000       000   000  000   000     000        000     000   000  0000  000
   000     0000000    000000000  000   000  0000000   0000000    000   000     000        000     000   000  000 0 000
   000     000   000  000   000  000   000  000       000   000  000   000     000        000     000   000  000  0000
   000     000   000  000   000  0000000    00000000  0000000     0000000      000        000      0000000   000   000
###

{ log, _ } = require 'kxk'

{ Stone, Bot } = require '../constants'

StoneMenu    = require './stonemenu'
CanvasButton = require './canvasbutton'
Materials    = require '../materials'

class TradeButton extends CanvasButton

    constructor: (div, inOut) ->
        
        super div, 'buttonCanvasInline'
        
        @stone = Stone.gelb
        @name = "TradeButton #{inOut}"
        
        @camera.updateProjectionMatrix()
        @render()
        
    #  0000000   0000000  00000000  000   000  00000000  
    # 000       000       000       0000  000  000       
    # 0000000   000       0000000   000 0 000  0000000   
    #      000  000       000       000  0000  000       
    # 0000000    0000000  00000000  000   000  00000000  
    
    initScene: ->
                
        @light = new THREE.DirectionalLight 0xffffff
        @light.position.set 0,10,6
        @scene.add @light
        
        @scene.add new THREE.AmbientLight 0xffffff
        
        @camera.fov = 40
        @camera.position.copy vec(0,2,1).normal().mul 22
        @camera.lookAt vec 0,7.6,0
        
    highlight: -> 

        new StoneMenu @
        
        @camera.fov = 33
        @camera.updateProjectionMatrix()
        @render()
    
    unhighlight: ->
        
        @camera.fov = 40
        @camera.updateProjectionMatrix()
        @render()
        
    click: -> 
        
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    render: ->

        @meshes.stone?.parent.remove @meshes.stone
        delete @meshes.stone

        bufg = @geomForCostRange @stone, 0, 10
        mesh = new THREE.Mesh bufg, Materials.cost[@stone]
        @scene.add mesh
        @meshes.stone = mesh
            
        super()

module.exports = TradeButton
