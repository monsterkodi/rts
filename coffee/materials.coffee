###
00     00   0000000   000000000  00000000  00000000   000   0000000   000       0000000
000   000  000   000     000     000       000   000  000  000   000  000      000     
000000000  000000000     000     0000000   0000000    000  000000000  000      0000000 
000 0 000  000   000     000     000       000   000  000  000   000  000           000
000   000  000   000     000     00000000  000   000  000  000   000  0000000  0000000 
###

Materials = 
    transparent: new THREE.MeshLambertMaterial  color:0x888888, depthWrite:false, transparent:true, opacity:0.1
    cage:   
        player:
            base:   new THREE.MeshPhongMaterial    color:Color.cage.player.base,  emissive:Color.cage.player.base,  specular:Color.cage.player.base, transparent:true, opacity:0.1, side:THREE.DoubleSide, depthWrite:false, shininess:100, dithering:true
            berta:  new THREE.MeshPhongMaterial    color:Color.cage.player.berta, emissive:Color.cage.player.berta, specular:Color.cage.player.berta, transparent:true, opacity:0.05, side:THREE.DoubleSide, depthWrite:false, shininess:100, dithering:true
        enemy:
            base:   new THREE.MeshPhongMaterial    color:Color.cage.enemy.base,  emissive:Color.cage.enemy.base,  specular:Color.cage.enemy.base, transparent:true, opacity:0.1, side:THREE.DoubleSide, depthWrite:false, shininess:100, dithering:true
            berta:  new THREE.MeshPhongMaterial    color:Color.cage.enemy.berta, emissive:Color.cage.enemy.berta, specular:Color.cage.enemy.berta, transparent:true, opacity:0.05, side:THREE.DoubleSide, depthWrite:false, shininess:100, dithering:true
            
    spark:      new THREE.LineBasicMaterial    color:Color.stone.red, linewidth: 8
    white:      new THREE.MeshStandardMaterial color:0xffffff
    highlight:  new THREE.MeshLambertMaterial  color:0xffffff, emissive:0xffffff, side:THREE.BackSide, depthWrite:false, transparent:true, opacity:0.2
    spent:      new THREE.MeshStandardMaterial color:0xffffff, metalness: 0.6, roughness: 0.7, side:THREE.DoubleSide
    path:       new THREE.MeshStandardMaterial color:Color.path, metalness: 0.9, roughness: 0.5
    segs:       new THREE.MeshStandardMaterial color:Color.segs, metalness: 0.9, roughness: 0.5
    stone: [   
                new THREE.MeshStandardMaterial color:Color.stone.red,     dithering:true # red
                new THREE.MeshStandardMaterial color:Color.stone.gelb,    dithering:true # gelb
                new THREE.MeshStandardMaterial color:Color.stone.blue,    dithering:true # blue
                new THREE.MeshStandardMaterial color:Color.stone.white,   dithering:true # white
                new THREE.MeshPhongMaterial    color:Color.stone.gray,    dithering:true # gray
                new THREE.MeshStandardMaterial color:Color.stone.monster, dithering:true # monster
                new THREE.MeshStandardMaterial color:Color.stone.cancer,  dithering:true, metalness: 1, roughness: 0 # cancer
    ]
    bot: [   
                new THREE.MeshStandardMaterial color:Color.bot.red   # red
                new THREE.MeshStandardMaterial color:Color.bot.gelb  # gelb
                new THREE.MeshStandardMaterial color:Color.bot.blue  # blue
                new THREE.MeshStandardMaterial color:Color.bot.white # white
                new THREE.MeshStandardMaterial color:Color.bot.gray,  metalness: 0.9, roughness: 0.5 # gray
    ]
    ai: [
                new THREE.MeshStandardMaterial color:Color.ai1,  metalness: 0.9, roughness: 0.6
                new THREE.MeshStandardMaterial color:Color.ai2,  metalness: 0.9, roughness: 0.6
                new THREE.MeshStandardMaterial color:Color.ai3,  metalness: 0.9, roughness: 0.6
                new THREE.MeshStandardMaterial color:Color.ai4,  metalness: 0.9, roughness: 0.6
    ]
    cost: [   
                new THREE.MeshStandardMaterial color:Color.stone.red   # red
                new THREE.MeshStandardMaterial color:Color.stone.gelb  # gelb
                new THREE.MeshStandardMaterial color:Color.stone.blue  # blue
                new THREE.MeshStandardMaterial color:Color.stone.white # white
                new THREE.MeshStandardMaterial color:Color.stone.gray  # cantAfford
    ]    
    state: 
        off:    new THREE.MeshStandardMaterial color:Color.menu.state.off, metalness: 0.6, roughness: 0.5
        on:     new THREE.MeshPhongMaterial    color:Color.menu.state.on
        paused: new THREE.MeshStandardMaterial color:Color.menu.state.paused, metalness: 0.5, roughness: 0.9
        
    menu:
        active:       new THREE.MeshStandardMaterial color:Color.menu.active,       metalness: 0.9, roughness: 0.75
        inactive:     new THREE.MeshStandardMaterial color:Color.menu.inactive,     metalness: 0.9, roughness: 0.75
        activeHigh:   new THREE.MeshStandardMaterial color:Color.menu.activeHigh,   metalness: 0.9, roughness: 0.75
        inactiveHigh: new THREE.MeshStandardMaterial color:Color.menu.inactiveHigh, metalness: 0.9, roughness: 0.75
        
    
module.exports = Materials
