// monsterkodi/kode 0.243.0

var _k_ = {assert: function (f,l,c,m,t) { if (!t) {console.log(f + ':' + l + ':' + c + ' ▴ ' + m)}}}

var Convert


Convert = (function ()
{
    function Convert (world)
    {
        this.world = world
    
        this["onConvertNodeToCtrl"] = this["onConvertNodeToCtrl"].bind(this)
        this["onConvertCtrlToNode"] = this["onConvertCtrlToNode"].bind(this)
        post.on('convertNodeToCtrl',this.onConvertNodeToCtrl)
        post.on('convertCtrlToNode',this.onConvertCtrlToNode)
    }

    Convert.prototype["onConvertCtrlToNode"] = function (ctrl)
    {
        console.log('onConvertCtrlToNode',ctrl)
    }

    Convert.prototype["onConvertNodeToCtrl"] = function (node)
    {
        var inNode, inPoints, inTrack, inTracks, mode, outNode, outPoints, outTrack, outTracks, t

        mode = node.commonMode()
        inTrack = node.inTracks[0]
        outTrack = node.outTracks[0]
        _k_.assert(".", 26, 8, "assert failed!" + " inTrack && outTrack", inTrack && outTrack)
        inTrack.explodeTrains()
        outTrack.explodeTrains()
        inNode = inTrack.nodeOpposite(node)
        outNode = outTrack.nodeOpposite(node)
        _k_.assert(".", 33, 8, "assert failed!" + " inNode && outNode", inNode && outNode)
        inTracks = inNode.siblingTracks(inTrack)
        outTracks = outNode.siblingTracks(outTrack)
        _k_.assert(".", 37, 8, "assert failed!" + " inTracks && outTracks", inTracks && outTracks)
        inPoints = inTrack.getCtrlPointsFromNode(inNode,true)
        outPoints = outTrack.getCtrlPointsFromNode(node)
        t = this.addTrack(inNode,outNode,inPoints.concat(outPoints))
        t.node[0] = inNode
        t.node[1] = outNode
        inTracks.push(t)
        outTracks.push(t)
        inTrack.del()
        outTrack.del()
        node.del()
        return t.setMode(mode)
    }

    return Convert
})()

module.exports = Convert