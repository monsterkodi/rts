###
00     00   0000000   000000000  00000000  00000000   000   0000000   000       0000000
000   000  000   000     000     000       000   000  000  000   000  000      000     
000000000  000000000     000     0000000   0000000    000  000000000  000      0000000 
000 0 000  000   000     000     000       000   000  000  000   000  000           000
000   000  000   000     000     00000000  000   000  000  000   000  0000000  0000000 
###

Materials = 
    transparent: new THREE.MeshLambertMaterial  color:0x888888, depthWrite:false, transparent:true, opacity:0.1
    white:      new THREE.MeshStandardMaterial color:0xffffff    
    highlight:  new THREE.MeshLambertMaterial  color:0xffffff, emissive:0xffffff, side:THREE.BackSide, depthWrite:true, transparent:true, opacity:0.2
    path:       new THREE.MeshStandardMaterial color:Color.path, metalness: 0.9, roughness: 0.5
    stone: [   
                new THREE.MeshStandardMaterial color:Color.stone.red,     dithering:true # red
                new THREE.MeshStandardMaterial color:Color.stone.gelb,    dithering:true # gelb
                new THREE.MeshStandardMaterial color:Color.stone.blue,    dithering:true # blue
                new THREE.MeshStandardMaterial color:Color.stone.white,   dithering:true # white
                new THREE.MeshPhongMaterial    color:Color.stone.gray,    dithering:true # gray
                new THREE.MeshStandardMaterial color:Color.stone.monster, dithering:true # monster
                new THREE.MeshStandardMaterial color:Color.stone.cancer,  dithering:true #, metalness: 1, roughness: 0 # cancer
    ]
    bot: [   
                new THREE.MeshStandardMaterial color:Color.bot.red   # red
                new THREE.MeshStandardMaterial color:Color.bot.gelb  # gelb
                new THREE.MeshStandardMaterial color:Color.bot.blue  # blue
                new THREE.MeshStandardMaterial color:Color.bot.white # white
                new THREE.MeshStandardMaterial color:Color.bot.gray,  metalness: 0.9, roughness: 0.5 # gray
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
