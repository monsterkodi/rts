// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}, in: function (a,l) {return (typeof l === 'string' && typeof a === 'string' && a.length ? '' : []).indexOf.call(l,a) >= 0}, assert: function (f,l,c,m,t) { if (!t) {console.log(f + ':' + l + ':' + c + ' ▴ ' + m)}}, empty: function (l) {return l==='' || l===null || l===undefined || l!==l || typeof(l) === 'object' && Object.keys(l).length === 0}}

var CurveCtrl, ModeSign, Rail, Track, Train

Rail = require('./rail')
CurveCtrl = require('../track/curvectrl')
ModeSign = require('./modesign')
Train = require('../train/train')

Track = (function ()
{
    Track["id"] = 0
    function Track (n1, n2, points, name)
    {
        var curveNum, index, p, _22_14_

        this.name = name
    
        this["nodeMoved"] = this["nodeMoved"].bind(this)
        this["nodeRotated"] = this["nodeRotated"].bind(this)
        this["ctrlMoved"] = this["ctrlMoved"].bind(this)
        this["onDoubleClick"] = this["onDoubleClick"].bind(this)
        this["onClick"] = this["onClick"].bind(this)
        this["onLeave"] = this["onLeave"].bind(this)
        this["onEnter"] = this["onEnter"].bind(this)
        this["del"] = this["del"].bind(this)
        this["toSave"] = this["toSave"].bind(this)
        this["onRemoveTrain"] = this["onRemoveTrain"].bind(this)
        Track.id++
        this.name = ((_22_14_=this.name) != null ? _22_14_ : `t${Track.id}`)
        this.node = [n1,n2]
        this.mode = ModeSign.twoway
        this.trains = []
        this.curve = new CurvePath
        this.ctrls = []
        this.exitBlockTrains = []
        points.unshift(n1.getPos())
        curveNum = points.length / 3
        if (curveNum % 1)
        {
            console.log('darfuk?')
        }
        points.push(n2.getPos())
        for (var _39_21_ = index = 0, _39_25_ = curveNum; (_39_21_ <= _39_25_ ? index < curveNum : index > curveNum); (_39_21_ <= _39_25_ ? ++index : --index))
        {
            p = points.slice(index * 3,index * 3 + 4)
            this.curve.add(new CubicBezierCurve3(p[0],p[1],p[2],p[3]))
        }
        for (var _43_21_ = index = 0, _43_25_ = curveNum; (_43_21_ <= _43_25_ ? index < curveNum : index > curveNum); (_43_21_ <= _43_25_ ? ++index : --index))
        {
            this.ctrls.push(new CurveCtrl(this,index))
        }
        this.modeSign = new ModeSign(this)
        this.createRail()
        this.mesh.track = this
        this.mesh.toSave = this.toSave
        this.mesh.toSave.key = 'tracks'
    }

    Track.prototype["hasTrain"] = function (train)
    {
        return this.trains.indexOf(train) >= 0
    }

    Track.prototype["addTrain"] = function (train)
    {
        if (!this.hasTrain())
        {
            this.trains.push(train)
            return this.addExitBlockForTrainAtNode(train,train.nextNode())
        }
    }

    Track.prototype["subTrain"] = function (train)
    {
        var i

        if ((i = this.trains.indexOf(train)) >= 0)
        {
            this.trains.splice(i,1)
            return this.removeFromExitBlockTrains(train)
        }
    }

    Track.prototype["explodeTrains"] = function ()
    {
        var train

        var list = _k_.list(this.trains)
        for (var _74_18_ = 0; _74_18_ < list.length; _74_18_++)
        {
            train = list[_74_18_]
            train.explode()
        }
    }

    Track.prototype["addExitBlockForTrainAtNode"] = function (train, node, visitedNodes)
    {
        var dir, ld, nextTrack, oppNode, oppTracks, sibTracks

        visitedNodes = (visitedNodes != null ? visitedNodes : [])
        if (_k_.in(node,visitedNodes))
        {
            return
        }
        visitedNodes.push(node)
        if (node === this.node[0])
        {
            ld = 6 / this.curve.getLength()
            dir = -1
        }
        else
        {
            ld = (this.curve.getLength() - 6) / this.curve.getLength()
            dir = 1
        }
        this.addExitBlock(train,node,ld,dir)
        oppTracks = node.oppositeTracks(this)
        sibTracks = node.siblingTracks(this)
        if ((oppTracks != null ? oppTracks.length : undefined) === 1 && (sibTracks != null ? sibTracks.length : undefined) === 1)
        {
            nextTrack = oppTracks[0]
            oppNode = nextTrack.nodeOpposite(node)
            return nextTrack.addExitBlockForTrainAtNode(train,oppNode,visitedNodes)
        }
    }

    Track.prototype["addExitBlock"] = function (train, node, ld, dir = 1)
    {
        var tangent

        if (_k_.in(train,this.exitBlockTrains))
        {
            _k_.assert(".", 115, 12, "assert failed!" + " node === this.exitBlockNode", node === this.exitBlockNode)
            _k_.assert(".", 116, 12, "assert failed!" + " this.blockMesh", this.blockMesh)
            return
        }
        this.exitBlockTrains.push(train)
        _k_.assert(".", 121, 8, "assert failed!" + " !this.exitBlockNode || this.exitBlockNode === node", !this.exitBlockNode || this.exitBlockNode === node)
        this.exitBlockNode = node
        if (!this.blockMesh)
        {
            this.blockMesh = new Mesh(Geom.triangle({size:[0.5,0.5,0.73]}),Materials.track.block)
            this.blockMesh.noHitTest = true
            tangent = this.curve.getTangentAt(ld)
            tangent.multiplyScalar(dir)
            this.curve.getPointAt(ld,this.blockMesh.position)
            this.blockMesh.quaternion.copy(Quaternion.unitVectors(Vector.unitY,tangent))
            return this.mesh.add(this.blockMesh)
        }
    }

    Track.prototype["hasExitBlockAtNode"] = function (node)
    {
        return node === this.exitBlockNode
    }

    Track.prototype["onRemoveTrain"] = function (train)
    {
        return this.removeFromExitBlockTrains(train)
    }

    Track.prototype["removeFromExitBlockTrains"] = function (train)
    {
        var index

        if ((index = this.exitBlockTrains.indexOf(train)) >= 0)
        {
            this.exitBlockTrains.splice(index,1)
            if (_k_.empty(this.exitBlockTrains))
            {
                return this.removeExitBlock()
            }
        }
    }

    Track.prototype["removeExitBlock"] = function ()
    {
        if (this.blockMesh)
        {
            _k_.assert(".", 149, 12, "assert failed!" + " this.exitBlockTrains.length === 0", this.exitBlockTrains.length === 0)
            this.blockMesh.removeFromParent()
            delete this.exitBlockNode
            return delete this.blockMesh
        }
    }

    Track.prototype["toSave"] = function ()
    {
        var ctrl, fix, i

        fix = function (p)
        {
            return {x:p.x.toFixed(1),y:p.y.toFixed(1),z:p.z.toFixed(1)}
        }
        ctrl = []
        for (var _165_17_ = i = 0, _165_21_ = this.curve.curves.length; (_165_17_ <= _165_21_ ? i < this.curve.curves.length : i > this.curve.curves.length); (_165_17_ <= _165_21_ ? ++i : --i))
        {
            ctrl.push(fix(this.curve.curves[i].v1))
            ctrl.push(fix(this.curve.curves[i].v2))
            if (i < this.curve.curves.length - 1)
            {
                ctrl.push(fix(this.curve.curves[i].v3))
            }
        }
        return {name:this.name,node:this.node.map(function (n)
        {
            return n.name
        }),mode:this.mode,ctrl:ctrl}
    }

    Track.prototype["del"] = function ()
    {
        var ctrl

        if (this.mesh)
        {
            this.explodeTrains()
            this.modeSign.del()
            post.emit('delTrack',this)
            ;(this.node[0] != null ? this.node[0].removeTrack(this) : undefined)
            ;(this.node[1] != null ? this.node[1].removeTrack(this) : undefined)
            delete this.mesh.handler
            world.removePickable(this.mesh)
            world.removeObject(this.mesh)
            var list = _k_.list(this.ctrls)
            for (var _189_21_ = 0; _189_21_ < list.length; _189_21_++)
            {
                ctrl = list[_189_21_]
                ctrl.del()
            }
            delete this.modeSign
            delete this.curve
            delete this.node
            delete this.ctrls
            delete this.mesh
            return delete this.rail
        }
    }

    Track.prototype["nextMode"] = function ()
    {
        return this.setMode((this.mode + 1) % 3)
    }

    Track.prototype["setMode"] = function (mode)
    {
        this.mode = mode
    
        return this.modeSign.updateMode()
    }

    Track.prototype["onEnter"] = function (hit, lastHit, event)
    {
        if (event.buttons === 0)
        {
            post.on('delete',this.del)
            this.mesh.material = Materials.track.highlight
            return world.cursorTrack = this
        }
    }

    Track.prototype["onLeave"] = function ()
    {
        post.removeListener('delete',this.del)
        this.mesh.material = Materials.track.rail
        if (world.cursorTrack === this)
        {
            return delete world.cursorTrack
        }
    }

    Track.prototype["onClick"] = function (hit, event)
    {
        var boxcars, delta, length, node

        if (event.button === 1)
        {
            this.nextMode()
        }
        if (event.button === 0)
        {
            boxcars = 1
            length = (boxcars + 1) * Train.carDist
            delta = this.deltaClosestToPoint(hit.point)
            if (this.mode === ModeSign.backward)
            {
                node = this.node[0]
                delta = this.curve.getLength() - delta
                if (delta < length)
                {
                    console.log('tail outside backward track')
                    return
                }
            }
            else
            {
                node = this.node[1]
                if (delta < length)
                {
                    console.log('tail outside forward track')
                    return
                }
            }
            return world.onAddTrain(this,delta,node,boxcars)
        }
    }

    Track.prototype["onDoubleClick"] = function ()
    {
        console.log('split track!')
    }

    Track.prototype["deltaClosestToPoint"] = function (point)
    {
        var curveLength, d, dists, i, md, mi, numPoints, points

        curveLength = this.curve.getLength()
        numPoints = parseInt(curveLength)
        points = this.curve.getSpacedPoints(numPoints)
        dists = points.map(function (p)
        {
            return p.distanceTo(point)
        })
        mi = 0
        md = Number.MAX_VALUE
        var list = _k_.list(dists)
        for (i = 0; i < list.length; i++)
        {
            d = list[i]
            if (d < md)
            {
                mi = i
                md = d
            }
        }
        return mi * curveLength / numPoints
    }

    Track.prototype["ctrlMoved"] = function ()
    {
        this.curve.updateArcLengths()
        return this.createRail()
    }

    Track.prototype["nodeRotated"] = function (n)
    {
        var dir

        dir = n.getDir()
        if (!(_k_.in(this,n.outTracks)))
        {
            dir.negate()
        }
        if (n === this.node[0])
        {
            this.ctrls[0].rotateStart(dir)
        }
        else if (n === this.node[1])
        {
            this.ctrls.slice(-1)[0].rotateEnd(dir)
        }
        this.curve.updateArcLengths()
        return this.createRail()
    }

    Track.prototype["nodeMoved"] = function (n)
    {
        if (n === this.node[0])
        {
            this.ctrls[0].moveStartTo(n.getPos())
        }
        else
        {
            this.ctrls.slice(-1)[0].moveEndTo(n.getPos())
        }
        this.curve.updateArcLengths()
        return this.createRail()
    }

    Track.prototype["createRail"] = function ()
    {
        var ld

        this.explodeTrains()
        this.rail = new Rail(this.curve,100)
        if (this.mesh)
        {
            this.mesh.geometry = this.rail
        }
        else
        {
            this.createMesh()
        }
        ld = 4 / this.curve.getLength()
        this.curve.getPointAt(ld,this.label.position)
        this.label.position.z = 0.36
        this.curve.getTangentAt(ld,Vector.tmp)
        this.label.quaternion.copy(Quaternion.unitVectors(Vector.unitY,Vector.tmp))
        return this.modeSign.updateMode()
    }

    Track.prototype["createMesh"] = function ()
    {
        this.mesh = new Mesh(this.rail,Materials.track.rail)
        this.mesh.name = this.name
        this.mesh.setShadow()
        this.mesh.handler = this
        this.label = world.addLabel({text:this.name,size:0.5,mono:true})
        this.mesh.add(this.label)
        world.addObject(this.mesh)
        return world.addPickable(this.mesh)
    }

    Track.prototype["nodeOpposite"] = function (node)
    {
        if (node === this.node[0])
        {
            return this.node[1]
        }
        else if (node === this.node[1])
        {
            return this.node[0]
        }
        else
        {
            console.log('nodeOpposite.dafuk?')
        }
    }

    Track.prototype["modeForNode"] = function (node)
    {
        if (this.mode === ModeSign.twoway)
        {
            return this.mode
        }
        if (node === this.node[this.mode % 2])
        {
            if (_k_.in(this,node.inTracks))
            {
                return ModeSign.forward
            }
            else
            {
                return ModeSign.backward
            }
        }
        else
        {
            if (_k_.in(this,node.outTracks))
            {
                return ModeSign.forward
            }
            else
            {
                return ModeSign.backward
            }
        }
    }

    Track.prototype["getLength"] = function ()
    {
        return this.curve.getLength()
    }

    Track.prototype["trainCurveDistance"] = function (train)
    {
        var nd

        if (train.path.revers[train.path.indexAtDelta()])
        {
            return nd = train.path.prevDistance()
        }
        else
        {
            return nd = train.path.nextDistance()
        }
    }

    Track.prototype["lastTrainDistance"] = function ()
    {
        var lastTrain

        if (_k_.empty(this.trains))
        {
            return this.getLength()
        }
        lastTrain = this.trains.slice(-1)[0]
        if (lastTrain.tailTrack() !== this)
        {
            return 0
        }
        return lastTrain.tailPrevDistance()
    }

    Track.prototype["getPoints"] = function ()
    {
        var curve, points

        points = []
        var list = _k_.list(this.curve.curves)
        for (var _389_18_ = 0; _389_18_ < list.length; _389_18_++)
        {
            curve = list[_389_18_]
            points = points.concat([curve.v0,curve.v1,curve.v2,curve.v3])
        }
        return points
    }

    Track.prototype["getCtrlPoints"] = function (includeLast)
    {
        var curve, points

        points = []
        var list = _k_.list(this.curve.curves)
        for (var _396_18_ = 0; _396_18_ < list.length; _396_18_++)
        {
            curve = list[_396_18_]
            points = points.concat([curve.v1,curve.v2,curve.v3])
        }
        if (!includeLast)
        {
            points.pop()
        }
        return points
    }

    Track.prototype["getPointsFromNode"] = function (node)
    {
        var points

        points = this.getPoints()
        if (node === this.node[1])
        {
            points.reverse()
        }
        return points
    }

    Track.prototype["getCtrlPointsFromNode"] = function (node, includeLast)
    {
        var points

        points = this.getCtrlPoints(includeLast)
        if (node === this.node[1])
        {
            points.reverse()
        }
        return points
    }

    return Track
})()

module.exports = Track