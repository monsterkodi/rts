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
    
    highlight:  new THREE.MeshLambertMaterial  color:0xffffff, emissive:0xffffff, side:THREE.BackSide, depthWrite:false, transparent:true, opacity:0.2
    path:       new THREE.MeshStandardMaterial color:0xbbbbbb, metalness: 0.9, roughness: 0.5, dithering:false
    stone: [   
                new THREE.MeshStandardMaterial color:Color.stone.red,   dithering:true # red
                new THREE.MeshStandardMaterial color:Color.stone.gelb,  dithering:true # gelb
                new THREE.MeshStandardMaterial color:Color.stone.blue,  dithering:true # blue
                new THREE.MeshStandardMaterial color:Color.stone.white, dithering:true # white
                new THREE.MeshPhongMaterial    color:Color.stone.gray,  dithering:true # gray
    ]
    bot: [   
                new THREE.MeshStandardMaterial color:Color.bot.red,   dithering:false # red
                new THREE.MeshStandardMaterial color:Color.bot.gelb,  dithering:false # gelb
                new THREE.MeshStandardMaterial color:Color.bot.blue,  dithering:false # blue
                new THREE.MeshStandardMaterial color:Color.bot.white, dithering:false # white
                new THREE.MeshStandardMaterial color:Color.bot.gray,  metalness: 0.9, roughness: 0.5, dithering:false # gray
    ]
    cost: [   
                new THREE.MeshStandardMaterial color:Color.cost.red,    dithering:false # red
                new THREE.MeshStandardMaterial color:Color.cost.gelb,   dithering:false # gelb
                new THREE.MeshStandardMaterial color:Color.cost.blue,   dithering:false # blue
                new THREE.MeshStandardMaterial color:Color.cost.white,  dithering:false # white
                new THREE.MeshStandardMaterial color:Color.cost.gray,   dithering:false # cantAfford
    ]    
    state: 
        off:    new THREE.MeshStandardMaterial color:0xff0000, metalness: 0.6, roughness: 0.5, dithering:false
        on:     new THREE.MeshPhongMaterial    color:0x111111, dithering:false
        
    menu:
        active:       new THREE.MeshStandardMaterial color:0xcccccc, metalness: 0.9, roughness: 0.75
        inactive:     new THREE.MeshStandardMaterial color:0x333333, metalness: 0.9, roughness: 0.75
        activeHigh:   new THREE.MeshStandardMaterial color:0xffffff, metalness: 0.9, roughness: 0.75
        inactiveHigh: new THREE.MeshStandardMaterial color:0x555555, metalness: 0.9, roughness: 0.75
    
module.exports = Materials
