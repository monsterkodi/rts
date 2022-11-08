// monsterkodi/kode 0.243.0

var _k_

var material, Materials


material = function (color, cfg)
{
    var clss

    cfg.color = color
    clss = THREE.MeshStandardMaterial
    switch (cfg.typ)
    {
        case 'lambert':
            clss = THREE.MeshLambertMaterial
            break
        case 'basic':
            clss = THREE.MeshBasicMaterial
            break
        case 'shadow':
            clss = THREE.ShadowMaterial
            break
        case 'toon':
            clss = THREE.MeshToonMaterial
            break
    }

    delete cfg.typ
    return new clss(cfg)
}
Materials = {misc:{transparent:material(0x888888,{typ:'lambert',depthWrite:false,transparent:true,opacity:0.1}),flat:material(0xffffff,{metalness:0.5,roughness:0.7,flatShading:true,dithering:true}),toon:material(0xffffff,{typ:'toon'})},shinyblack:material(0x000000,{metalness:0.6,roughness:0.1,flatShading:true}),wireframe:material(0x888888,{typ:'basic',wireframe:true}),floor:material(0x222222,{dithering:true}),shadow:material(0x000000,{typ:'shadow',opacity:0.2,depthWrite:false}),ctrl:{transparent:material(0x888888,{typ:'lambert',depthWrite:false,transparent:true,opacity:0.0}),highlight:material(0xff0000,{metalness:0.5,roughness:0.5,emissive:0xff0000}),start:material(0xff0000,{metalness:0.5,roughness:0.5}),curve:material(0x111111,{metalness:0.8,roughness:0.45,flatShading:true,dithering:true})},compass:{head:material(Colors.compass.head,{metalness:0.5,roughness:0.5}),wheel:material(0x111111,{metalness:0.8,roughness:0.45,dithering:true}),dot0:material(Colors.compass.center,{metalness:0.5,roughness:0.5}),dot1:material(Colors.compass.head,{metalness:0.5,roughness:0.5}),dot2:material(Colors.compass.center,{metalness:0.5,roughness:0.5}),dot3:material(Colors.compass.head,{metalness:0.5,roughness:0.5}),dot4:material(Colors.compass.center,{metalness:0.5,roughness:0.5}),dot5:material(Colors.compass.head,{metalness:0.5,roughness:0.5}),dot6:material(Colors.compass.center,{metalness:0.5,roughness:0.5}),dot7:material(Colors.compass.head,{metalness:0.5,roughness:0.5})},train:{window:material(0x000000,{metalness:0.5,roughness:0.2}),body:material(0xffffff,{metalness:0.2,roughness:0.4}),piston:material(0x000000,{metalness:0.1,roughness:0.8}),light:material(0x000000,{metalness:0.1,roughness:0.8})},station:{side:material(0x000000,{metalness:0.5,roughness:0.2,dithering:true,side:THREE.DoubleSide}),central:material(0xffffff,{metalness:0.2,roughness:0.4}),train:material(0x888888,{metalness:0.3,roughness:0.4,dithering:true})},mining:{chalk:material(Colors.mining.chalk,{metalness:0.6,roughness:0.05,emissive:0x777777,dithering:true}),water:material(Colors.mining.water,{metalness:0.6,roughness:0.01,emissive:0x4444aa,dithering:true}),blood:material(Colors.mining.blood,{metalness:0.6,roughness:0.1,emissive:0xaa0000,dithering:true}),stuff:material(Colors.mining.stuff,{metalness:0.6,roughness:0.01,emissive:0x888800,dithering:true})},selector:{chalk:material(0xffffff,{metalness:0.2,roughness:0.4}),water:material(0xffffff,{metalness:0.2,roughness:0.4}),blood:material(0xffffff,{metalness:0.2,roughness:0.4}),stuff:material(0xffffff,{metalness:0.2,roughness:0.4})},track:{rail:material(Colors.track,{metalness:0.8,roughness:0.45,flatShading:true,dithering:true}),highlight:material(0xff0000,{metalness:0.5,roughness:0.5,emissive:0xff0000}),block:material(0xff0000,{metalness:0.5,roughness:0.5,emissive:0xff0000}),mode:{twoway:material(Colors.track,{metalness:0.5,roughness:0.5}),oneway:material(Colors.track,{metalness:0.5,roughness:0.5,emissive:0x222222}),highlight:material(0xff0000,{metalness:0.5,roughness:0.5,emissive:0xff0000})}},node:{center:material(Colors.track,{metalness:0.8,roughness:0.45,flatShading:true,dithering:true}),out:material(Colors.node.out,{metalness:0.5,roughness:0.5}),in:material(Colors.node.in,{metalness:0.5,roughness:0.5}),highlightIn:material(Colors.node.in,{metalness:0.5,roughness:0.5,emissive:Colors.node.in}),highlightOut:material(Colors.node.out,{metalness:0.5,roughness:0.5,emissive:Colors.node.out})},menu:{active:material(Colors.menu.active,{metalness:0.2,roughness:0.5,emissive:Colors.menu.active}),inactive:material(Colors.menu.inactive,{metalness:0.9,roughness:0.75}),activeHigh:material(Colors.menu.activeHigh,{metalness:0.9,roughness:0.75}),inactiveHigh:material(Colors.menu.inactiveHigh,{metalness:0.9,roughness:0.75})},physics:{chain:material(0x000000,{metalness:0.5,roughness:0.2})},setWire:function (wire)
{
    var k, m, t

    prefs.set('wire',wire)
    var list = ['node','ctrl','compass','train','track','station','misc']
    for (var _90_14_ = 0; _90_14_ < list.length; _90_14_++)
    {
        t = list[_90_14_]
        for (k in Materials[t])
        {
            m = Materials[t][k]
            m.wireframe = wire
        }
    }
},getWire:function ()
{
    return prefs.get('wire')
},toggleWire:function ()
{
    return Materials.setWire(!Materials.getWire())
},setFlat:function (flat)
{
    var k, m

    prefs.set('flat',flat)
    for (k in Materials.train)
    {
        m = Materials.train[k]
        m.flatShading = flat
        m.needsUpdate = true
    }
},getFlat:function ()
{
    return prefs.get('flat')
},toggleFlat:function ()
{
    return Materials.setFlat(!Materials.getFlat())
}}
module.exports = Materials