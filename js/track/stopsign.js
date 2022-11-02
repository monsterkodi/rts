// monsterkodi/kode 0.243.0

var _k_

var ModeSign


ModeSign = (function ()
{
    function ModeSign (track, node)
    {
        var atStart, geom

        this.track = track
        this.node = node
    
        atStart = node === this.track.node[0]
        geom = Geom.box({size:10})
        this.mesh = new Mesh(geom,Materials.track.rail)
        this.mesh.position.copy(this.node.getPos())
        world.scene.add(this.mesh)
    }

    ModeSign.prototype["del"] = function ()
    {
        return this.mesh.removeFromParent()
    }

    return ModeSign
})()

module.exports = StopSign