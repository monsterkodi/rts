###
 0000000   0000000   000       0000000   00000000 
000       000   000  000      000   000  000   000
000       000   000  000      000   000  0000000  
000       000   000  000      000   000  000   000
 0000000   0000000   0000000   0000000   000   000
###

{ log, _ } = require 'kxk'

THREE = require 'three'

color = (v) -> new THREE.Color v

Color =

    menu:
        background:      color 0x181818
        backgroundHover: color 0x202020
        progress:        color 0x8888ff
        active:          color 0xcccccc
        inactive:        color 0x333333
        activeHigh:      color 0xffffff
        inactiveHigh:    color 0x555555
        state:
            off:         color 0xff0000
            on:          color 0x111111

    stone: 
        red:             color 0x881111
        gelb:            color 0xffaa00
        blue:            color 0x2222aa
        white:           color 0x44aaff
        gray:            color 0x111111

    spent: 
        red:             color 0x441111
        gelb:            color 0xaa4411
        blue:            color 0x2222aa
        white:           color 0x2288aa
        
    cost:
        blue:            color 0x4444ff
        
    bot:
        gray:            color 0xccccdd
        
    path:                color 0xbbbbbb
    
    monster:             color 0x333333

Color.cost.red   = Color.stone.red
Color.cost.gelb  = Color.stone.gelb
Color.cost.white = Color.stone.white
Color.cost.gray  = Color.stone.gray

Color.bot.red    = Color.stone.red
Color.bot.gelb   = Color.stone.gelb
Color.bot.blue   = Color.stone.blue
Color.bot.white  = Color.stone.white

Color.stones = [Color.stone.red, Color.stone.gelb, Color.stone.blue, Color.stone.white, Color.stone.gray, Color.monster]
        
module.exports = Color
