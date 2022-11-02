// monsterkodi/kode 0.243.0

var _k_

class Synt
{
    constructor (config, ctx, gain)
    {
        var _36_25_

        this.config = config
        this.ctx = ctx
        this.gain = gain
    
        this.organ2 = this.organ2.bind(this)
        this.piano2 = this.piano2.bind(this)
        this.freqs = [4186.01,4434.92,4698.63,4978.03,5274.04,5587.65,5919.91,6271.93,6644.88,7040.00,7458.62,7902.13]
        this.config.duration = ((_36_25_=this.config.duration) != null ? _36_25_ : 0.3)
        this.isr = 1.0 / 44100
        this.initBuffers()
    }

    initBuffers ()
    {
        this.sampleLength = this.config.duration * 44100
        this.sampleLength = Math.floor(this.sampleLength)
        return this.createBuffers()
    }

    createBuffers ()
    {
        return this.samples = new Array(108)
    }

    playNote (noteIndex)
    {
        var audioBuffer, buffer, frequency, func, i, node, sample, sampleIndex, w, x

        if (!(this.samples[noteIndex] != null))
        {
            this.samples[noteIndex] = new Float32Array(this.sampleLength)
            frequency = this.freq(noteIndex)
            w = 2.0 * Math.PI * frequency
            func = this[this.config.instrument]
            for (var _59_32_ = sampleIndex = 0, _59_36_ = this.sampleLength; (_59_32_ <= _59_36_ ? sampleIndex < this.sampleLength : sampleIndex > this.sampleLength); (_59_32_ <= _59_36_ ? ++sampleIndex : --sampleIndex))
            {
                x = sampleIndex / (this.sampleLength - 1)
                this.samples[noteIndex][sampleIndex] = func(sampleIndex * this.isr,w,x)
            }
        }
        sample = this.samples[noteIndex]
        audioBuffer = this.ctx.createBuffer(1,sample.length,44100)
        buffer = audioBuffer.getChannelData(0)
        for (var _66_18_ = i = 0, _66_22_ = sample.length; (_66_18_ <= _66_22_ ? i < sample.length : i > sample.length); (_66_18_ <= _66_22_ ? ++i : --i))
        {
            buffer[i] = sample[i]
        }
        node = this.ctx.createBufferSource()
        node.buffer = audioBuffer
        node.connect(this.gain)
        node.state = node.noteOn
        return node.start(0)
    }

    freq (noteIndex)
    {
        return this.freqs[noteIndex % 12] / Math.pow(2,(8 - noteIndex / 12)).toFixed(3)
    }

    setDuration (v)
    {
        if (this.config.duration !== v)
        {
            this.config.duration = v
            return this.initBuffers()
        }
    }

    fmod (x, y)
    {
        return x % y
    }

    sign (x)
    {
        return (x > 0.0) && 1.0 || -1.0
    }

    frac (x)
    {
        return x % 1.0
    }

    sqr (a, x)
    {
        if (Math.sin(x) > a)
        {
            return 1.0
        }
        else
        {
            return -1.0
        }
    }

    step (a, x)
    {
        return (x >= a) && 1.0 || 0.0
    }

    over (x, y)
    {
        return 1.0 - (1.0 - x) * (1.0 - y)
    }

    mix (a, b, x)
    {
        return a + (b - a) * Math.min(Math.max(x,0.0),1.0)
    }

    saw (x, a)
    {
        var f

        f = x % 1.0
        if ((f < a))
        {
            return (f / a)
        }
        else
        {
            return (1.0 - (f - a) / (1.0 - a))
        }
    }

    grad (n, x)
    {
        n = (n << 13) ^ n
        n = (n * (n * n * 15731 + 789221) + 1376312589)
        if ((n & 0x20000000))
        {
            return -x
        }
        else
        {
            return x
        }
    }

    noise (x)
    {
        var a, b, f, i, w

        i = Math.floor(x)
        f = x - i
        w = f * f * f * (f * (f * 6.0 - 15.0) + 10.0)
        a = this.grad(i + 0,f + 0.0)
        b = this.grad(i + 1,f - 1.0)
        return a + (b - a) * w
    }

    piano1 (t, w, x)
    {
        var d, wt, y

        wt = w * t
        y = 0.6 * Math.sin(1.0 * wt) * Math.exp(-0.0008 * wt)
        y += 0.3 * Math.sin(2.0 * wt) * Math.exp(-0.0010 * wt)
        y += 0.1 * Math.sin(4.0 * wt) * Math.exp(-0.0015 * wt)
        y += 0.2 * y * y * y
        y *= 0.9 + 0.1 * Math.cos(70.0 * t)
        y = 2.0 * y * Math.exp(-22.0 * t) + y
        d = 0.8
        if (x > d)
        {
            y *= Math.pow(1 - (x - d) / (1 - d),2)
        }
        return y
    }

    piano2 (t, w, x)
    {
        var a, b, d, r, rt, y, y2, y3

        t = t + 0.00015 * this.noise(12 * t)
        rt = t
        r = t * w * 0.2
        r = this.fmod(r,1)
        a = 0.15 + 0.6 * (rt)
        b = 0.65 - 0.5 * (rt)
        y = 50 * r * (r - 1) * (r - 0.2) * (r - a) * (r - b)
        r = t * w * 0.401
        r = this.fmod(r,1)
        a = 0.12 + 0.65 * (rt)
        b = 0.67 - 0.55 * (rt)
        y2 = 50 * r * (r - 1) * (r - 0.4) * (r - a) * (r - b)
        r = t * w * 0.399
        r = this.fmod(r,1)
        a = 0.14 + 0.55 * (rt)
        b = 0.66 - 0.65 * (rt)
        y3 = 50 * r * (r - 1) * (r - 0.8) * (r - a) * (r - b)
        y += 0.02 * this.noise(1000 * t)
        y /= (t * w * 0.0015 + 0.1)
        y2 /= (t * w * 0.0020 + 0.1)
        y3 /= (t * w * 0.0025 + 0.1)
        y = (y + y2 + y3) / 3
        d = 0.8
        if (x > d)
        {
            y *= Math.pow(1 - (x - d) / (1 - d),2)
        }
        return y
    }

    piano3 (t, w, x)
    {
        var a, b, d, tt, y

        tt = 1 - t
        a = Math.sin(t * w * 0.5) * Math.log(t + 0.3) * tt
        b = Math.sin(t * w) * t * 0.4
        y = (a + b) * tt
        d = 0.8
        if (x > d)
        {
            y *= Math.pow(1 - (x - d) / (1 - d),2)
        }
        return y
    }

    piano4 (t, w, x)
    {
        var y

        y = Math.sin(w * t)
        return y *= 1 - x * x * x * x
    }

    piano5 (t, w, x)
    {
        var wt, y

        wt = w * t
        y = 0.6 * Math.sin(1.0 * wt) * Math.exp(-0.0008 * wt)
        y += 0.3 * Math.sin(2.0 * wt) * Math.exp(-0.0010 * wt)
        y += 0.1 * Math.sin(4.0 * wt) * Math.exp(-0.0015 * wt)
        y += 0.2 * y * y * y
        y *= 0.5 + 0.5 * Math.cos(70.0 * t)
        y = 2.0 * y * Math.exp(-22.0 * t) + y
        return y *= 1 - x * x * x * x
    }

    organ1 (t, w, x)
    {
        var a, y

        y = 0.6 * Math.cos(w * t) * Math.exp(-4 * t)
        y += 0.4 * Math.cos(2 * w * t) * Math.exp(-3 * t)
        y += 0.01 * Math.cos(4 * w * t) * Math.exp(-1 * t)
        y = y * y * y + y * y * y * y * y + y * y
        a = 0.5 + 0.5 * Math.cos(3.14 * x)
        y = Math.sin(y * a * 3.14)
        return y *= 20 * t * Math.exp(-0.1 * x)
    }

    organ2 (t, w, x)
    {
        var a1, a2, a3, wt, y

        wt = w * t
        a1 = 0.5 + 0.5 * Math.cos(0 + t * 12)
        a2 = 0.5 + 0.5 * Math.cos(1 + t * 8)
        a3 = 0.5 + 0.5 * Math.cos(2 + t * 4)
        y = this.saw(0.2500 * wt,a1) * Math.exp(-2 * x)
        y += this.saw(0.1250 * wt,a2) * Math.exp(-3 * x)
        y += this.saw(0.0625 * wt,a3) * Math.exp(-4 * x)
        return y *= 0.8 + 0.2 * Math.cos(64 * t)
    }

    bell1 (t, w, x)
    {
        var wt, y

        wt = w * t
        y = 0.100 * Math.exp(-t / 1.000) * Math.sin(0.56 * wt)
        y += 0.067 * Math.exp(-t / 0.900) * Math.sin(0.56 * wt)
        y += 0.100 * Math.exp(-t / 0.650) * Math.sin(0.92 * wt)
        y += 0.180 * Math.exp(-t / 0.550) * Math.sin(0.92 * wt)
        y += 0.267 * Math.exp(-t / 0.325) * Math.sin(1.19 * wt)
        y += 0.167 * Math.exp(-t / 0.350) * Math.sin(1.70 * wt)
        y += 0.146 * Math.exp(-t / 0.250) * Math.sin(2.00 * wt)
        y += 0.133 * Math.exp(-t / 0.200) * Math.sin(2.74 * wt)
        y += 0.133 * Math.exp(-t / 0.150) * Math.sin(3.00 * wt)
        y += 0.100 * Math.exp(-t / 0.100) * Math.sin(3.76 * wt)
        y += 0.133 * Math.exp(-t / 0.075) * Math.sin(4.07 * wt)
        return y *= 1 - x * x * x * x
    }

    bell2 (t, w, x)
    {
        var wt, y

        wt = w * t
        y = 0.100 * Math.exp(-t / 1.000) * Math.sin(0.56 * wt)
        y += 0.067 * Math.exp(-t / 0.900) * Math.sin(0.56 * wt)
        y += 0.100 * Math.exp(-t / 0.650) * Math.sin(0.92 * wt)
        y += 0.180 * Math.exp(-t / 0.550) * Math.sin(0.92 * wt)
        y += 0.267 * Math.exp(-t / 0.325) * Math.sin(1.19 * wt)
        y += 0.167 * Math.exp(-t / 0.350) * Math.sin(1.70 * wt)
        y += 2.0 * y * Math.exp(-22.0 * t)
        return y *= 1 - x * x * x * x
    }

    bell3 (t, w, x)
    {
        var wt, y

        wt = w * t
        y = 0
        y += 0.100 * Math.exp(-t / 1) * Math.sin(0.25 * wt)
        y += 0.200 * Math.exp(-t / 0.75) * Math.sin(0.50 * wt)
        y += 0.400 * Math.exp(-t / 0.5) * Math.sin(1.00 * wt)
        y += 0.200 * Math.exp(-t / 0.25) * Math.sin(2.00 * wt)
        y += 0.100 * Math.exp(-t / 0.1) * Math.sin(4.00 * wt)
        y += 2.0 * y * Math.exp(-22.0 * t)
        return y *= 1 - x * x * x * x
    }

    bell4 (t, w, x)
    {
        var wt, y

        wt = w * t
        y = 0
        y += 0.100 * Math.exp(-t / 0.9) * Math.sin(0.62 * wt)
        y += 0.200 * Math.exp(-t / 0.7) * Math.sin(0.86 * wt)
        y += 0.500 * Math.exp(-t / 0.5) * Math.sin(1.00 * wt)
        y += 0.200 * Math.exp(-t / 0.2) * Math.sin(1.27 * wt)
        y += 0.100 * Math.exp(-t / 0.1) * Math.sin(1.40 * wt)
        y += 2.0 * y * Math.exp(-22.0 * t)
        return y *= 1 - x * x * x * x
    }

    string (t, w, x)
    {
        var f, wt, y

        wt = w * t
        f = Math.sin(0.251 * wt) * Math.PI
        y = 0.5 * Math.sin(1 * wt + f) * Math.exp(-1.0 * x)
        y += 0.4 * Math.sin(2 * wt + f) * Math.exp(-2.0 * x)
        y += 0.3 * Math.sin(4 * wt + f) * Math.exp(-3.0 * x)
        y += 0.2 * Math.sin(8 * wt + f) * Math.exp(-4.0 * x)
        y += 1.0 * y * Math.exp(-10.0 * t)
        y *= 1 - x * x * x * x
        return y
    }

    flute (t, w, x)
    {
        var d, y

        y = 6.0 * x * Math.exp(-2 * x) * Math.sin(w * t)
        y *= 0.6 + 0.4 * Math.sin(32 * (1 - x))
        d = 0.87
        if (x > d)
        {
            y *= Math.pow(1 - (x - d) / (1 - d),2)
        }
        return y
    }
}

module.exports = Synt