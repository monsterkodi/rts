###
00     00   0000000   000000000  00000000  00000000   000   0000000   000       0000000
000   000  000   000     000     000       000   000  000  000   000  000      000     
000000000  000000000     000     0000000   0000000    000  000000000  000      0000000 
000 0 000  000   000     000     000       000   000  000  000   000  000           000
000   000  000   000     000     00000000  000   000  000  000   000  0000000  0000000 
###

THREE = require 'three'

Materials = 
    
    highlight:  new THREE.MeshLambertMaterial  color:0xffffff, emissive:0xffffff, side:THREE.BackSide, depthWrite:false, transparent:true, opacity:0.2
    # highlight:  new THREE.MeshLambertMaterial  color:0x000000, side:THREE.BackSide, depthWrite:false, transparent:true, opacity:0.5
    botGray:    new THREE.MeshStandardMaterial color:0xccccdd, metalness: 0.9, roughness: 0.5, dithering:false
    botWhite:   new THREE.MeshStandardMaterial color:0xccccdd, metalness: 0.9, roughness: 0.5, dithering:false
    path:       new THREE.MeshStandardMaterial color:0xbbbbbb, metalness: 0.9, roughness: 0.5, dithering:false
    stone: [   
                new THREE.MeshPhongMaterial    color:0x111111, dithering:true # gray
                new THREE.MeshStandardMaterial color:0x880000, dithering:true # red
                new THREE.MeshStandardMaterial color:0x008800, dithering:true # green
                new THREE.MeshStandardMaterial color:0x000088, dithering:true # blue
                new THREE.MeshStandardMaterial color:0xffff00, dithering:true # yellow
                new THREE.MeshStandardMaterial color:0x000000, dithering:true # black
                new THREE.MeshStandardMaterial color:0xffffff, dithering:true # white
    ]
    bot: [   
                new THREE.MeshStandardMaterial color:0x111111, dithering:false # gray
                new THREE.MeshStandardMaterial color:0xdd0000, dithering:false # red
                new THREE.MeshStandardMaterial color:0x008800, dithering:false # green
                new THREE.MeshStandardMaterial color:0x0000ff, dithering:false # blue
                new THREE.MeshStandardMaterial color:0xffff00, dithering:false # yellow
                new THREE.MeshStandardMaterial color:0x000000, dithering:false # black
                new THREE.MeshStandardMaterial color:0xffffff, dithering:false # white
    ]
    
module.exports = Materials
