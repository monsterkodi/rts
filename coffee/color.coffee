###
 0000000   0000000   000       0000000   00000000 
000       000   000  000      000   000  000   000
000       000   000  000      000   000  0000000  
000       000   000  000      000   000  000   000
 0000000   0000000   0000000   0000000   000   000
###

{ log, _ } = require 'kxk'

THREE = require 'three'

Color =

    menu:
        background:      new THREE.Color 0x181818
        backgroundHover: new THREE.Color 0x202020
        progress:        new THREE.Color 0x8888ff

    stone: 
        red:             new THREE.Color 0x881111
        gelb:            new THREE.Color 0xff8822
        white:           new THREE.Color 0x44aaff
        gray:            new THREE.Color 0x111111
        blue:            new THREE.Color 0x222288

    spent: 
        red:             new THREE.Color 0x441111
        gelb:            new THREE.Color 0xaa4411
        white:           new THREE.Color 0x2288aa
        blue:            new THREE.Color 0x2222aa
        
    cost:
        blue:            new THREE.Color 0x4444ff
        
    bot:
        gray:            new THREE.Color 0xccccdd

Color.cost.red   = Color.stone.red
Color.cost.gelb  = Color.stone.gelb
Color.cost.white = Color.stone.white
Color.cost.gray  = Color.stone.gray

Color.bot.red   = Color.stone.red
Color.bot.gelb  = Color.stone.gelb
Color.bot.blue  = Color.stone.blue
Color.bot.white = Color.stone.white
        
module.exports = Color
