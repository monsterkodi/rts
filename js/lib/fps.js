// monsterkodi/kode 0.243.0

var _k_ = {clamp: function (l,h,v) { var ll = Math.min(l,h), hh = Math.max(l,h); if (!_k_.isNum(v)) { v = ll }; if (v < ll) { v = ll }; if (v > hh) { v = hh }; if (!_k_.isNum(v)) { v = ll }; return v }, isNum: function (o) {return !isNaN(o) && !isNaN(parseFloat(o)) && (isFinite(o) || o === Infinity || o === -Infinity)}}

class FPS
{
    constructor ()
    {
        var green, i, red, x, y

        this.draw = this.draw.bind(this)
        this.width = 180
        this.height = 60
        this.canvas = elem('canvas',{class:'fps',height:2 * this.height,width:2 * this.width})
        y = parseInt(-this.height / 2)
        x = parseInt(this.width / 2)
        this.canvas.style.transform = `translate3d(${x}px, ${y}px, 0px) scale3d(0.5, 0.5, 1)`
        this.colors = []
        for (i = 0; i <= 32; i++)
        {
            red = parseInt(32 + (255 - 32) * _k_.clamp(0,1,(i - 16) / 16))
            green = parseInt(32 + (255 - 32) * _k_.clamp(0,1,(i - 32) / 32))
            this.colors.push(`rgb(${red}, ${green}, 32)`)
        }
        this.history = []
        for (i = 0; i < 2 * this.width; i++)
        {
            this.history[i] = 0
        }
        this.index = 0
        this.last = window.performance.now()
        $("#main").appendChild(this.canvas)
    }

    draw ()
    {
        var ctx, h, i, ms, time

        time = window.performance.now()
        this.index += 1
        if (this.index > 2 * this.width)
        {
            this.index = 0
        }
        this.history[this.index] = time - this.last
        this.canvas.height = this.canvas.height
        ctx = this.canvas.getContext('2d')
        for (var _55_18_ = i = 0, _55_22_ = this.history.length; (_55_18_ <= _55_22_ ? i < this.history.length : i > this.history.length); (_55_18_ <= _55_22_ ? ++i : --i))
        {
            ms = Math.max(0,this.history[i] - 17)
            ctx.fillStyle = this.colors[_k_.clamp(0,32,parseInt(ms))]
            h = Math.min(ms,60)
            ctx.fillRect((2 * this.width - this.index + i) % (2 * this.width),0,2,h)
        }
        return this.last = time
    }
}

module.exports = FPS