// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}, clamp: function (l,h,v) { var ll = Math.min(l,h), hh = Math.max(l,h); if (!_k_.isNum(v)) { v = ll }; if (v < ll) { v = ll }; if (v > hh) { v = hh }; if (!_k_.isNum(v)) { v = ll }; return v }, isNum: function (o) {return !isNaN(o) && !isNaN(parseFloat(o)) && (isFinite(o) || o === Infinity || o === -Infinity)}}

var CanvasButton, deg2rad, drag

clamp = require('kxk').clamp
deg2rad = require('kxk').deg2rad
drag = require('kxk').drag

CanvasButton = require('./canvasbutton')
class DialButton extends CanvasButton
{
    constructor (div, clss)
    {
        super(div,clss,vec(-4,4,6),vec(0,0,1).normal().mul(10))
    
        this.onDrag = this.onDrag.bind(this)
        this.name = 'DialButton'
        this.drag = new drag({target:this.canvas,onStart:this.onDrag,onMove:this.onDrag})
    }

    dialChanged (index)
    {}

    setDial (index)
    {
        var dot

        var list = _k_.list(this.dots)
        for (var _29_16_ = 0; _29_16_ < list.length; _29_16_++)
        {
            dot = list[_29_16_]
            dot.material = Materials.menu.inactive
            dot.scale.set(1,1,1)
        }
        this.dots[index].material = Materials.menu.active
        this.dots[index].scale.set(3,3,3)
        return this.update()
    }

    initCamera ()
    {
        var s

        s = 5.5
        return this.camera = new THREE.OrthographicCamera(-s,s,s,-s,1,10)
    }

    initScene ()
    {
        super.initScene()
    
        return this.initDots()
    }

    initDots ()
    {
        var geom, i, mesh, p

        this.dots = []
        for (i = -6; i <= 6; i++)
        {
            geom = Geom.sphere({radius:0.3})
            geom.rotateX(deg2rad(90))
            p = vec(0,4,0).rotate(vec(0,0,1),-i * 22.5)
            mesh = new Mesh(geom,Materials.menu.inactive)
            mesh.position.copy(p)
            this.dots.push(mesh)
            this.scene.add(mesh)
        }
    }

    onDrag (drag, event)
    {
        var angle, br, ctr2Pos, sectn

        br = this.canvas.getBoundingClientRect()
        ctr2Pos = vec(br.left + 50,br.top + 50,0).to(drag.pos)
        ctr2Pos.y = -ctr2Pos.y
        angle = Math.sign(ctr2Pos.dot(vec(1,0,0))) * ctr2Pos.angle(vec(0,1,0))
        sectn = _k_.clamp(-6,6,Math.round(angle / 22.5))
        this.setDial(sectn + 6)
        return this.dialChanged(sectn + 6)
    }
}

module.exports = DialButton