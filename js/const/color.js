// monsterkodi/kode 0.243.0

var _k_

var color, Color


color = function (v)
{
    return new THREE.Color(v)
}
Color = {black:color(0x000000),white:color(0xffffff),compass:{head:color(0x666666),center:color(0xff0000)},dot:[color(0xff0000),color(0x555555),color(0xff0000),color(0x555555),color(0xff0000),color(0x555555),color(0xff0000),color(0x555555)],node:{center:color(0x111111),out:color(0x666666),in:color(0x666666)},train:{yellow:color(0xffff00),orange:color(0xff8800),red:color(0xff0000),green:color(0x008800),blue:color(0x8888ff),white:color(0xffffff)},track:color(0x111111),menu:{background:color(0x181818),backgroundHover:color(0x202020),progress:color(0x8888ff),disconnected:color(0x000000),active:color(0x333333),inactive:color(0x333333),activeHigh:color(0xffffff),inactiveHigh:color(0x555555)},clear:color(0x444444),segs:color(0x111111),path:color(0xbbbbbb)}
module.exports = Color