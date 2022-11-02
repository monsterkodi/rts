// monsterkodi/kode 0.243.0

var _k_ = {clamp: function (l,h,v) { var ll = Math.min(l,h), hh = Math.max(l,h); if (!_k_.isNum(v)) { v = ll }; if (v < ll) { v = ll }; if (v > hh) { v = hh }; if (!_k_.isNum(v)) { v = ll }; return v }, isNum: function (o) {return !isNaN(o) && !isNaN(parseFloat(o)) && (isFinite(o) || o === Infinity || o === -Infinity)}}

var post, prefs, randRange, Synt

clamp = require('kxk').clamp
post = require('kxk').post
prefs = require('kxk').prefs
randRange = require('kxk').randRange

Synt = require('./synt')
class Sound
{
    constructor ()
    {
        this.volumeIndex = 3
        this.volume = 0
        this.ctx = new (window.AudioContext || window.webkitAudioContext)()
        this.gain = this.ctx.createGain()
        this.gain.connect(this.ctx.destination)
        this.synt = {}
        this.setSynt({enemy:{instrument:'bell3'},player:{instrument:'bell3'},menu:{instrument:'flute'},stone:{instrument:'bell1'},science:{instrument:'bell2'},state:{instrument:'bell4'},fail:{instrument:'string'}})
        this.setVolume(prefs.get('volume',this.volumeIndex))
    }

    play (o, n, c = 0)
    {
        return this.synt[o].playNote(((function ()
        {
            switch (n)
            {
                case 'won':
                    return 5 * 12 + c + parseInt(randRange(0,4))

                case 'lost':
                    return 6 * 12 + c + parseInt(randRange(0,2))

                case 'highlight':
                    return 40 + c

                case 'enqueue':
                    return 55 + c

                case 'off':
                    return 50 + c

                case 'on':
                    return 60 + c

                case 'stone':
                    return 45 + c

                default:
                    return 6 * 12 + c + parseInt(randRange(0,2))
            }

        }).bind(this))())
    }

    setSynt (synt)
    {
        var k, v

        for (k in synt)
        {
            v = synt[k]
            this.synt[k] = new Synt(v,this.ctx,this.gain)
        }
    }

    setVolume (volumeIndex)
    {
        this.volumeIndex = _k_.clamp(0,config.volume.length - 1,volumeIndex)
        this.volume = config.volume[this.volumeIndex]
        this.gain.gain.value = this.volume
        prefs.set('volume',this.volumeIndex)
        return post.emit('volume',this.volumeIndex)
    }
}

module.exports = Sound