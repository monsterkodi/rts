###
000000000   0000000    0000000    0000000   000      00000000  0000000    000   000  000000000  000000000   0000000   000   000
   000     000   000  000        000        000      000       000   000  000   000     000        000     000   000  0000  000
   000     000   000  000  0000  000  0000  000      0000000   0000000    000   000     000        000     000   000  000 0 000
   000     000   000  000   000  000   000  000      000       000   000  000   000     000        000     000   000  000  0000
   000      0000000    0000000    0000000   0000000  00000000  0000000     0000000      000        000      0000000   000   000
###

{ log, _ } = require 'kxk'

Geometry     = require '../geometry'
Materials    = require '../materials'
CanvasButton = require './canvasbutton'
SubMenu      = require './submenu'

class ToggleButton extends CanvasButton

    constructor: (div, cb, state='off', states=['off', 'on']) ->
        
        super div, 'toggleButton canvasButtonInline'

        @name   = "ToggleButton"
        @states = states
        @cb     = cb
        
        @setState state
        
    click: -> 
        
        @setState @states[(@states.indexOf(@state)+1)%@states.length]
        @cb @state
        
    setState: (newState) ->
        
        @state = newState
        
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
        @camera.position.copy vec(0.1,0.3,1).normal().mul 12
        @camera.lookAt vec 0,0,0
        
    highlight: -> 

        SubMenu.close()
        
        @camera.fov = 33
        @camera.updateProjectionMatrix()
        @render()
    
    unhighlight: ->

        @camera.fov = 40
        @camera.updateProjectionMatrix()
        @render()
        
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    render: ->

        @meshes.state?.parent.remove @meshes.state
        delete @meshes.state

        bufg = Geometry.state @state
        
        mesh = new THREE.Mesh bufg, Materials.state[@state]
        @scene.add mesh
        @meshes.state = mesh
            
        super()
        
module.exports = ToggleButton
