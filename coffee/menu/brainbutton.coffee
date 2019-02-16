###
0000000    00000000    0000000   000  000   000  0000000    000   000  000000000  000000000   0000000   000   000
000   000  000   000  000   000  000  0000  000  000   000  000   000     000        000     000   000  0000  000
0000000    0000000    000000000  000  000 0 000  0000000    000   000     000        000     000   000  000 0 000
000   000  000   000  000   000  000  000  0000  000   000  000   000     000        000     000   000  000  0000
0000000    000   000  000   000  000  000   000  0000000     0000000      000        000      0000000   000   000
###

{ first, last, deg2rad, log, _ } = require 'kxk'

{ Bot, Stone } = require '../constants'

Science      = require '../science'
Geometry     = require '../geometry'
Materials    = require '../materials'
CanvasButton = require './canvasbutton'

class BrainButton extends CanvasButton

    constructor: (div, scienceKey) ->

        super div, 'brainButton buttonCanvas'
        
        @name = "BrainButton #{scienceKey}"
        @scienceKey = scienceKey
            
        @render()
        
    click: -> Science.queue @scienceKey
    
    #  0000000   0000000  00000000  000   000  00000000  
    # 000       000       000       0000  000  000       
    # 0000000   000       0000000   000 0 000  0000000   
    #      000  000       000       000  0000  000       
    # 0000000    0000000  00000000  000   000  00000000  
    
    initScene: ->
                
        @light = new THREE.DirectionalLight 0xffffff
        @light.position.set -10,10,10
        @scene.add @light
        
        @scene.add new THREE.AmbientLight 0xffffff
        
        @camera.fov = 40
        @camera.position.copy vec(0,0,1).normal().mul 1.5
        @camera.lookAt vec 0,0,0
        @camera.updateProjectionMatrix()
    
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    render: ->
        
        construct = rts.world.construct
        mat = Materials.menu.active

        # 0000000     0000000   000000000  
        # 000   000  000   000     000     
        # 0000000    000   000     000     
        # 000   000  000   000     000     
        # 0000000     0000000      000     
        
        @meshes.bot?.parent.remove @meshes.bot
        delete @meshes.bot

        name = first @scienceKey.split '.'
        bot = Bot.base
        if name in Bot.keys
            bot  = Bot[name]
            geom = construct.botGeoms[construct.geomForBotType bot]
        else 
            switch name 
                when 'tube', 'path'
                    geom = Geometry.tube 0.6
                else
                    geom = new THREE.SphereGeometry 0.5, 12, 12
            
        mesh = new THREE.Mesh geom, mat
        
        switch name
            when 'trade', 'brain'
                mesh.rotateX deg2rad -90
        
        @scene.add mesh
        @meshes.bot = mesh
            
        # 000000000   0000000   00000000   000   0000000  
        #    000     000   000  000   000  000  000       
        #    000     000   000  00000000   000  000       
        #    000     000   000  000        000  000       
        #    000      0000000   000        000   0000000  
        
        @meshes.topic?.parent.remove @meshes.topic
        delete @meshes.topic
        
        topic = last @scienceKey.split '.'
  
        geom = switch topic 
            when 'limit', 'length'
                mat = Materials.stone[Stone.white]
                g = new THREE.Geometry 
                g.merge Geometry.plus 0.1, -0.05
                g.merge Geometry.plus 0.1,  0.05
                g
                
            when 'speed'
                mat = Materials.stone[Stone.red]
                g = new THREE.Geometry 
                g.merge Geometry.speed 0.1, -0.05
                g.merge Geometry.speed 0.1,  0.05
                g
                
            when 'gap'
                mat = Materials.stone[Stone.red]
                g = new THREE.Geometry 
                g.merge Geometry.box 0.09, -0.055
                g.merge Geometry.box 0.09,  0.055
                g
                
            else
                mat = Materials.stone[Stone.gelb]
                g = new THREE.Geometry 
                g.merge Geometry.box 0.05, -0.03
                g.merge Geometry.box 0.05, -0.03, -0.055
                g.merge Geometry.box 0.05,  0.03, -0.055
                g
                
        geom.translate 0.17, 0.17, 0.55
                
        bufg = new THREE.BufferGeometry().fromGeometry geom
        mesh = new THREE.Mesh bufg, mat
        @scene.add mesh
        @meshes.topic = mesh
        
        #  0000000  000000000   0000000   00000000    0000000  
        # 000          000     000   000  000   000  000       
        # 0000000      000     000000000  0000000    0000000   
        #      000     000     000   000  000   000       000  
        # 0000000      000     000   000  000   000  0000000   
        
        @meshes.stars?.parent.remove @meshes.stars
        delete @meshes.stars
        
        g = new THREE.Geometry 
        g.merge Geometry.star 0.1, -0.2
        g.merge Geometry.star 0.1, -0.1
        g.merge Geometry.star 0.1,  0.0
        g.merge Geometry.star 0.1,  0.1
        g.merge Geometry.star 0.1,  0.2
        g.translate 0, -0.3, 0.5
        
        bufg = new THREE.BufferGeometry().fromGeometry g
        mesh = new THREE.Mesh bufg, Materials.menu.inactive
        @scene.add mesh
        @meshes.stars = mesh
        
        super()
        
module.exports = BrainButton
