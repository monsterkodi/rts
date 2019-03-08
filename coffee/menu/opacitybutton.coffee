###
 0000000   00000000    0000000    0000000  000  000000000  000   000    
000   000  000   000  000   000  000       000     000      000 000     
000   000  00000000   000000000  000       000     000       00000      
000   000  000        000   000  000       000     000        000       
 0000000   000        000   000   0000000  000     000        000       
###

DialButton = require './dialbutton'

class OpacityButton extends DialButton

    constructor: (div) ->
    
        super div, 'opacityButton canvasButtonInline'
        
        @name = 'OpacityButton'
        
        post.on 'worldOpacity', @onWorldOpacity        
        post.on 'cageOpacity', @onCageOpacity        
        @onWorldOpacity()
        @onCageOpacity()
            
    # 0000000     0000000   000000000   0000000  
    # 000   000  000   000     000     000       
    # 000   000  000   000     000     0000000   
    # 000   000  000   000     000          000  
    # 0000000     0000000      000     0000000   
    
    initDots: ->
        
        merg = new THREE.Geometry
        for i in [-7..-1]
            geom = Geometry.sphere 0.5
            geom.rotateX deg2rad 90
            p = vec(0,4,0).rotate vec(0,0,1), i*22.5
            geom.translate p.x, p.y, p.z
            merg.merge geom

        for i in [1..7]
            geom = Geometry.sphere 0.5
            geom.rotateX deg2rad 90
            p = vec(0,4,0).rotate vec(0,0,1), i*22.5
            geom.translate p.x, p.y, p.z
            merg.merge geom
            
        bufg = new THREE.BufferGeometry().fromGeometry merg
        mesh = new THREE.Mesh bufg, Materials.menu.inactive
        @scene.add mesh
        
        geom = Geometry.sphere 0.6
        geom.rotateX deg2rad 90
        bufg = new THREE.BufferGeometry().fromGeometry geom
        @dot1 = new THREE.Mesh bufg, Materials.menu.active
        @scene.add @dot1

        geom = Geometry.sphere 0.6
        geom.rotateX deg2rad 90
        bufg = new THREE.BufferGeometry().fromGeometry geom
        @dot2 = new THREE.Mesh bufg, Materials.menu.active
        @scene.add @dot2
        
    # 0000000    00000000    0000000    0000000   
    # 000   000  000   000  000   000  000        
    # 000   000  0000000    000000000  000  0000  
    # 000   000  000   000  000   000  000   000  
    # 0000000    000   000  000   000   0000000   
    
    onDrag: (drag, event) => 
        
        br = @canvas.getBoundingClientRect()
        
        ctr2Pos = vec(br.left+50, br.top+50).to drag.pos
        ctr2Pos.y = -ctr2Pos.y
        
        angle = Math.sign(ctr2Pos.dot(vec 1,0,0)) * ctr2Pos.angle(vec 0,1,0)
        if ctr2Pos.x < 0
            sectn = clamp -7, -1, Math.round angle/22.5
            rts.world.setOpacity sectn+7
        else
            sectn = clamp 1, 7, Math.round angle/22.5
            rts.world.setCageOpacity 6-sectn+1
            
        @update()
            
    # 000   000   0000000   00000000   000      0000000    
    # 000 0 000  000   000  000   000  000      000   000  
    # 000000000  000   000  0000000    000      000   000  
    # 000   000  000   000  000   000  000      000   000  
    # 00     00   0000000   000   000  0000000  0000000    
    
    onWorldOpacity: =>
        
        p = vec(0,4,0).rotate vec(0,0,1), 180-22.5-rts.world.opacityIndex*22.5
        @dot1.position.copy p
        @update()
        
    #  0000000   0000000    0000000   00000000  
    # 000       000   000  000        000       
    # 000       000000000  000  0000  0000000   
    # 000       000   000  000   000  000       
    #  0000000  000   000   0000000   00000000  
    
    onCageOpacity: =>
        
        p = vec(0,4,0).rotate vec(0,0,1), 180+22.5+rts.world.cageOpacityIndex*22.5
        @dot2.position.copy p
        @update()

module.exports = OpacityButton
