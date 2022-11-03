// monsterkodi/kode 0.243.0

var _k_ = {isFunc: function (o) {return typeof o === 'function'}}

class Debug
{
    constructor ()
    {
        var getCannon, getInfo, setCannon, setInfo

        this.doToggle = this.doToggle.bind(this)
        this.updateBrightness = this.updateBrightness.bind(this)
        this.updateWorldSpeed = this.updateWorldSpeed.bind(this)
        this.decrWorldSpeed = this.decrWorldSpeed.bind(this)
        this.incrWorldSpeed = this.incrWorldSpeed.bind(this)
        this.resetWorldSpeed = this.resetWorldSpeed.bind(this)
        this.hide = this.hide.bind(this)
        this.show = this.show.bind(this)
        this.elem = elem({class:'debug',style:"position:absolute; z-index:1; bottom:10px; left:10px;"})
        this.help = elem({class:'debug',style:'position:absolute; z-index:1; bottom:10px; left:150px;',parent:this.elem})
        this.mats = elem({class:'debug',style:'position:absolute; z-index:1; bottom:10px; left:300px;',parent:this.elem})
        this.grid = elem({class:'debug',style:'position:absolute; z-index:1; bottom:10px; left:450px;',parent:this.elem})
        this.shdw = elem({class:'debug',style:'position:absolute; z-index:1; bottom:10px; left:600px;',parent:this.elem})
        this.tool = elem({class:'debug',style:'position:absolute; z-index:1; bottom:10px; left:750px;',parent:this.elem})
        this.worldSpeed = this.value({text:'speed',value:world.speed.toFixed(1),reset:this.resetWorldSpeed,incr:this.incrWorldSpeed,decr:this.decrWorldSpeed})
        this.brightness = this.value({text:'light',value:rts.getBrightness().toFixed(1),reset:rts.resetBrightness,incr:rts.incrBrightness,decr:rts.decrBrightness})
        this.toggles = {}
        setInfo = function (v)
        {
            return prefs.set('info',v)
        }
        getInfo = function ()
        {
            return prefs.get('info')
        }
        setCannon = function (v)
        {
            return prefs.set('get',v)
        }
        getCannon = function ()
        {
            return prefs.get('get')
        }
        this.toggle({text:'info',set:setInfo,get:getInfo})
        this.toggle({text:'wire',parent:this.mats,set:Materials.setWire,get:Materials.getWire})
        this.toggle({text:'flat',parent:this.mats,set:Materials.setFlat,get:Materials.getFlat})
        this.toggle({text:'lable',pref:'lable',parent:this.mats,set:world.setLabels,get:world.getLabels})
        this.toggle({text:'axes',pref:'axes',parent:this.help,obj:rts.axesHelper,key:'visible'})
        this.toggle({text:'arrow',pref:'arrow',parent:this.help,obj:rts.arrowHelper,key:'visible'})
        this.toggle({text:'cannon',pref:'cannon',parent:this.help,set:setCannon,get:getCannon})
        this.toggle({text:'shadow',pref:'shadow',parent:this.shdw,obj:rts.shadowCameraHelper,key:'visible'})
        this.toggle({text:'light',pref:'light',parent:this.shdw,obj:rts.lightShadowHelper,key:'visible'})
        this.toggle({text:'grid',pref:'grid',parent:this.grid,obj:rts.gridHelper,key:'visible'})
        this.toggle({text:'floor',pref:'floor',parent:this.grid,obj:world.floor,key:'visible'})
        this.button({text:'~trains',parent:this.tool,click:world.delTrains})
        this.button({text:'~tracks',parent:this.tool,click:world.delTracks})
        this.button({text:'~tidyup',parent:this.tool,click:world.tidyUp})
        document.body.appendChild(this.elem)
        post.on('worldSpeed',this.updateWorldSpeed)
        post.on('brightness',this.updateBrightness)
        post.on('toggle',this.doToggle)
    }

    show ()
    {
        return this.elem.style.display = 'block'
    }

    hide ()
    {
        return this.elem.style.display = 'none'
    }

    del ()
    {
        post.removeListener('worldSpeed',this.updateWorldSpeed)
        return this.elem.remove()
    }

    resetWorldSpeed ()
    {
        return world.resetSpeed()
    }

    incrWorldSpeed ()
    {
        return world.incrSpeed()
    }

    decrWorldSpeed ()
    {
        return world.decrSpeed()
    }

    updateWorldSpeed ()
    {
        var _77_19_

        if ((this.worldSpeed != null)) { this.worldSpeed.children[2].innerHTML = world.speed.toFixed(1) }
        return 0
    }

    updateBrightness ()
    {
        var _81_19_

        if ((this.brightness != null)) { this.brightness.children[2].innerHTML = rts.getBrightness().toFixed(1) }
        return 0
    }

    value (cfg)
    {
        var box, dec, inc, lbl, val

        lbl = elem({class:'label',text:cfg.text})
        val = elem({class:'value',text:cfg.value,click:cfg.reset})
        inc = elem({class:'incr',text:'>',click:cfg.incr})
        dec = elem({class:'decr',text:'<',click:cfg.decr})
        return box = elem({class:'box',children:[lbl,dec,val,inc],parent:this.elem})
    }

    button (cfg)
    {
        var _92_88_

        return elem({class:'btn',text:cfg.text,click:cfg.click,parent:((_92_88_=cfg.parent) != null ? _92_88_ : this.elem)})
    }

    static tglBtn (btn, cfg)
    {
        var val, _111_14_

        if (_k_.isFunc(cfg.get) && _k_.isFunc(cfg.set))
        {
            cfg.set(!cfg.get())
        }
        else
        {
            cfg.obj[cfg.key] = !cfg.obj[cfg.key]
        }
        if (_k_.isFunc(cfg.get))
        {
            val = cfg.get()
        }
        else
        {
            val = cfg.obj[cfg.key]
        }
        if (cfg.pref)
        {
            prefs.set(cfg.pref,val)
        }
        btn.classList[(val ? 'add' : 'remove')]('on')
        return (typeof cfg.cb === "function" ? cfg.cb(val) : undefined)
    }

    toggle (cfg)
    {
        var btn, tgl, val, _119_80_

        tgl = function (cfg)
        {
            return function (event)
            {
                return Debug.tglBtn(btn,cfg)
            }
        }
        btn = elem({class:'btn',text:cfg.text,click:tgl(cfg),parent:((_119_80_=cfg.parent) != null ? _119_80_ : this.elem)})
        if (_k_.isFunc(cfg.get))
        {
            val = cfg.get()
        }
        else if (cfg.pref)
        {
            val = prefs.get(cfg.pref)
        }
        else
        {
            val = cfg.obj[cfg.key]
        }
        if (!val)
        {
            val = false
        }
        if (_k_.isFunc(cfg.set))
        {
            cfg.set(val)
        }
        else
        {
            cfg.obj[cfg.key] = val
        }
        if (val)
        {
            btn.classList.add('on')
        }
        btn.cfg = cfg
        this.toggles[cfg.text] = btn
        return btn
    }

    doToggle (name)
    {
        var t

        t = this.toggles[name]
        return Debug.tglBtn(t,t.cfg)
    }

    clampZero (v, d, m)
    {
        v += d
        v = Math.max(0,v)
        v = Math.min(v,m)
        if (v < 0.01)
        {
            v = 0
        }
        return v
    }
}

module.exports = Debug