###
00     00   0000000   000000000  00000000  00000000   000   0000000   000       0000000
000   000  000   000     000     000       000   000  000  000   000  000      000     
000000000  000000000     000     0000000   0000000    000  000000000  000      0000000 
000 0 000  000   000     000     000       000   000  000  000   000  000           000
000   000  000   000     000     00000000  000   000  000  000   000  0000000  0000000 
###

THREE = require 'three'

Color = require './color'

Materials = 
    
    spark:      new THREE.LineBasicMaterial    color:Color.stone.red, linewidth: 8
    cage:       new THREE.PointsMaterial       color:Color.cage, size:0.04
    white:      new THREE.MeshStandardMaterial color:0xffffff
    highlight:  new THREE.MeshLambertMaterial  color:0xffffff, emissive:0xffffff, side:THREE.BackSide, depthWrite:false, transparent:true, opacity:0.2
    spent:      new THREE.MeshStandardMaterial color:0xffffff, metalness: 0.6, roughness: 0.7, side:THREE.DoubleSide
    path:       new THREE.MeshStandardMaterial color:Color.path, metalness: 0.9, roughness: 0.5
    stone: [   
                new THREE.MeshStandardMaterial color:Color.stone.red,     dithering:true # red
                new THREE.MeshStandardMaterial color:Color.stone.gelb,    dithering:true # gelb
                new THREE.MeshStandardMaterial color:Color.stone.blue,    dithering:true # blue
                new THREE.MeshStandardMaterial color:Color.stone.white,   dithering:true # white
                new THREE.MeshPhongMaterial    color:Color.stone.gray,    dithering:true # gray
                new THREE.MeshStandardMaterial color:Color.stone.monster, dithering:true # monster
    ]
    bot: [   
                new THREE.MeshStandardMaterial color:Color.bot.red   # red
                new THREE.MeshStandardMaterial color:Color.bot.gelb  # gelb
                new THREE.MeshStandardMaterial color:Color.bot.blue  # blue
                new THREE.MeshStandardMaterial color:Color.bot.white # white
                new THREE.MeshStandardMaterial color:Color.bot.gray,  metalness: 0.9, roughness: 0.5 # gray
    ]
    cost: [   
                new THREE.MeshStandardMaterial color:Color.cost.red   # red
                new THREE.MeshStandardMaterial color:Color.cost.gelb  # gelb
                new THREE.MeshStandardMaterial color:Color.cost.blue  # blue
                new THREE.MeshStandardMaterial color:Color.cost.white # white
                new THREE.MeshStandardMaterial color:Color.cost.gray  # cantAfford
    ]    
    state: 
        off:    new THREE.MeshStandardMaterial color:Color.menu.state.off, metalness: 0.6, roughness: 0.5
        on:     new THREE.MeshPhongMaterial    color:Color.menu.state.on
        
    menu:
        active:       new THREE.MeshStandardMaterial color:Color.menu.active,       metalness: 0.9, roughness: 0.75
        inactive:     new THREE.MeshStandardMaterial color:Color.menu.inactive,     metalness: 0.9, roughness: 0.75
        activeHigh:   new THREE.MeshStandardMaterial color:Color.menu.activeHigh,   metalness: 0.9, roughness: 0.75
        inactiveHigh: new THREE.MeshStandardMaterial color:Color.menu.inactiveHigh, metalness: 0.9, roughness: 0.75
        
    
module.exports = Materials
