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
    path:       new THREE.MeshStandardMaterial color:0xbbbbbb, metalness: 0.9, roughness: 0.5, dithering:false
    stone: [   
                new THREE.MeshPhongMaterial    color:0x111111, dithering:true # gray
                new THREE.MeshStandardMaterial color:0x881111, dithering:true # red
                new THREE.MeshStandardMaterial color:0xff8822, dithering:true # gelb
                new THREE.MeshStandardMaterial color:0x222288, dithering:true # blue
                new THREE.MeshStandardMaterial color:0x44aaff, dithering:true # white
    ]
    bot: [   
                new THREE.MeshStandardMaterial color:0xccccdd, metalness: 0.9, roughness: 0.5, dithering:false # gray
                new THREE.MeshStandardMaterial color:0x881111, dithering:false # red
                new THREE.MeshStandardMaterial color:0xff8822, dithering:false # gelb
                new THREE.MeshStandardMaterial color:0x222288, dithering:false # blue
                new THREE.MeshStandardMaterial color:0x44aaff, dithering:false # white
    ]
    
module.exports = Materials
