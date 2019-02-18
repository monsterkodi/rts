###
0000000    00000000    0000000   000  000   000  0000000    000   000  000000000  000000000   0000000   000   000
000   000  000   000  000   000  000  0000  000  000   000  000   000     000        000     000   000  0000  000
0000000    0000000    000000000  000  000 0 000  0000000    000   000     000        000     000   000  000 0 000
000   000  000   000  000   000  000  000  0000  000   000  000   000     000        000     000   000  000  0000
0000000    000   000  000   000  000  000   000  0000000     0000000      000        000      0000000   000   000
###

{ first, last, deg2rad, log, _ } = require 'kxk'

{ Bot, Stone } = require '../constants'

Color        = require '../color'
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
        
    click: => 
        
        if Science.enqueue @scienceKey
            @render()
    
    highlight: =>
        @high = true
        super()

    unhighlight: =>
        @high = false
        super()
        
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
    
    stars: -> Science.nextStars @scienceKey
        
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    render: ->

        for key,mesh of @meshes
            mesh.parent?.remove mesh
        @meshes = {}
        
        stars = @stars()
        if stars > Science.maxStars @scienceKey
            return super()
        
        construct = rts.world.construct
        mat = Materials.menu.active

        # 0000000     0000000   000000000  
        # 000   000  000   000     000     
        # 0000000    000   000     000     
        # 000   000  000   000     000     
        # 0000000     0000000      000     
        
        [science, key] = @scienceKey.split '.'
        
        bot = Bot.base
        if science in Bot.keys
            bot  = Bot[science]
            geom = construct.botGeoms[construct.geomForBotType bot]
        else 
            switch science 
                when 'tube', 'path'
                    geom = Geometry.tube 0.6
                else
                    geom = new THREE.SphereGeometry 0.5, 12, 12
            
        mesh = new THREE.Mesh geom, mat
        
        switch science
            when 'trade', 'brain'
                mesh.rotateX deg2rad -90
        
        @scene.add mesh
        @meshes.bot = mesh
            
        # 000000000   0000000   00000000   000   0000000  
        #    000     000   000  000   000  000  000       
        #    000     000   000  00000000   000  000       
        #    000     000   000  000        000  000       
        #    000      0000000   000        000   0000000  
                
        geom = switch key 
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
               
        if @high
            geom.translate 0.14, 0.15, 0.55
        else
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
                                
        g = new THREE.Geometry 
        g.merge Geometry.star 0.1,  0.0
        g.merge Geometry.star 0.1,  0.1 if stars > 1
        g.merge Geometry.star 0.1,  0.2 if stars > 2
        g.merge Geometry.star 0.1,  0.3 if stars > 3
        g.merge Geometry.star 0.1,  0.4 if stars > 4
        if @high
            g.translate -0.1*stars/2+0.05, -0.295, 0.3
        else
            g.translate -0.1*stars/2+0.05, -0.3, 0.5
        
        bufg = new THREE.BufferGeometry().fromGeometry g
        mesh = new THREE.Mesh bufg, Materials.menu.activeHigh
        @scene.add mesh
        @meshes.starsActive = mesh
                    
        super()
        
        ctx = @canvas.getContext '2d'
        
        progress = 100*state.progress[science][key][stars]/state.scienceSteps[stars]
        ctx.fillStyle = Color.menu.progress.getStyle()
        ctx.fillRect 100-progress, 199, 2*progress, 1
        
module.exports = BrainButton