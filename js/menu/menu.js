// monsterkodi/kode 0.257.0

var _k_

var SpeedButton

SpeedButton = require('./speedbutton')
class Menu
{
    constructor ()
    {
        var main

        this.onMouseLeave = this.onMouseLeave.bind(this)
        this.onMouseMove = this.onMouseMove.bind(this)
        this.onMouseEnter = this.onMouseEnter.bind(this)
        this.onMouseDown = this.onMouseDown.bind(this)
        this.onMouseOut = this.onMouseOut.bind(this)
        this.onMouseOver = this.onMouseOver.bind(this)
        this.onClick = this.onClick.bind(this)
        main = $("#main")
        this.div = elem({class:'buttons',style:"left:0px; top:0px"})
        main.appendChild(this.div)
        this.mousePos = vec()
        this.buttons = {speed:new SpeedButton(main)}
        this.div.addEventListener('mouseenter',this.onMouseEnter)
        this.div.addEventListener('mouseleave',this.onMouseLeave)
        this.div.addEventListener('mousemove',this.onMouseMove)
        main.addEventListener('mouseover',this.onMouseOver)
        main.addEventListener('mouseout',this.onMouseOut)
        main.addEventListener('mousedown',this.onMouseDown)
        main.addEventListener('click',this.onClick)
    }

    onClick (event)
    {
        var _31_67_, _31_74_

        this.calcMouse(event)
        return ((_31_67_=event.target.button) != null ? typeof (_31_74_=_31_67_.click) === "function" ? _31_74_(event) : undefined : undefined)
    }

    onMouseOver (event)
    {
        var _32_67_, _32_78_

        this.calcMouse(event)
        return ((_32_67_=event.target.button) != null ? typeof (_32_78_=_32_67_.highlight) === "function" ? _32_78_(event) : undefined : undefined)
    }

    onMouseOut (event)
    {
        var _33_67_, _33_80_

        this.calcMouse(event)
        return ((_33_67_=event.target.button) != null ? typeof (_33_80_=_33_67_.unhighlight) === "function" ? _33_80_(event) : undefined : undefined)
    }

    onMouseDown (event)
    {
        var _37_27_, _37_40_, _38_27_, _38_39_

        this.calcMouse(event)
        if (event.button === 1)
        {
            ;((_37_27_=event.target.button) != null ? typeof (_37_40_=_37_27_.middleClick) === "function" ? _37_40_(event) : undefined : undefined)
        }
        if (event.button === 2)
        {
            return ((_38_27_=event.target.button) != null ? typeof (_38_39_=_38_27_.rightClick) === "function" ? _38_39_(event) : undefined : undefined)
        }
    }

    onMouseEnter (event)
    {}

    onMouseMove (event)
    {
        this.calcMouse(event)
        return stopEvent(event)
    }

    onMouseLeave (event)
    {
        return this.calcMouse(event)
    }

    calcMouse (event)
    {
        var br

        br = this.div.getBoundingClientRect()
        this.mousePos.x = event.clientX - br.left
        return this.mousePos.y = event.clientY - br.top
    }

    animate (delta)
    {
        var button, key

        for (key in this.buttons)
        {
            button = this.buttons[key]
            button.animate(delta)
        }
    }
}

module.exports = Menu