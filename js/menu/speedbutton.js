// monsterkodi/kode 0.243.0

var _k_

var DialButton

DialButton = require('./dialbutton')
class SpeedButton extends DialButton
{
    constructor (div)
    {
        super(div,'speedButton canvasButtonInline')
    
        this.onWorldSpeed = this.onWorldSpeed.bind(this)
        this.name = 'SpeedButton'
        post.on('worldSpeed',this.onWorldSpeed)
        this.onWorldSpeed()
    }

    dialChanged (index)
    {
        return world.setSpeed(index)
    }

    onWorldSpeed ()
    {
        return this.setDial(world.speedIndex)
    }
}

module.exports = SpeedButton