// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}, assert: function (f,l,c,m,t) { if (!t) {console.log(f + ':' + l + ':' + c + ' ▴ ' + m)}}, in: function (a,l) {return (typeof l === 'string' && typeof a === 'string' && a.length ? '' : []).indexOf.call(l,a) >= 0}}

var Compass, CurveCtrl, Node

CurveCtrl = require('./curvectrl')
Compass = require('./compass')

Node = (function ()
{
    Node["id"] = 0
    Node["clickMode"] = false
    Node["skipCenter"] = false
    function Node (cfg)
    {
        var geom, label, pos, _22_26_, _23_27_

        this["onRemoveTrain"] = this["onRemoveTrain"].bind(this)
        this["compassRotated"] = this["compassRotated"].bind(this)
        this["onRotate"] = this["onRotate"].bind(this)
        this["getPos"] = this["getPos"].bind(this)
        this["onDrag"] = this["onDrag"].bind(this)
        this["onDragDone"] = this["onDragDone"].bind(this)
        this["onOutDrag"] = this["onOutDrag"].bind(this)
        this["onInDrag"] = this["onInDrag"].bind(this)
        this["onMouseUp"] = this["onMouseUp"].bind(this)
        this["onMouseDown"] = this["onMouseDown"].bind(this)
        this["onMouseMove"] = this["onMouseMove"].bind(this)
        this["onClickInOut"] = this["onClickInOut"].bind(this)
        this["onLeaveCenter"] = this["onLeaveCenter"].bind(this)
        this["onEnterCenter"] = this["onEnterCenter"].bind(this)
        this["onLeaveOut"] = this["onLeaveOut"].bind(this)
        this["onEnterOut"] = this["onEnterOut"].bind(this)
        this["onLeaveIn"] = this["onLeaveIn"].bind(this)
        this["onEnterIn"] = this["onEnterIn"].bind(this)
        this["onClickCenter"] = this["onClickCenter"].bind(this)
        this["onDoubleClickCenter"] = this["onDoubleClickCenter"].bind(this)
        this["del"] = this["del"].bind(this)
        this["toSave"] = this["toSave"].bind(this)
        Node.id++
        this.name = ((_22_26_=cfg.name) != null ? _22_26_ : `n${Node.id}`)
        this.fixed = ((_23_27_=cfg.fixed) != null ? _23_27_ : false)
        pos = vec(cfg.pos)
        this.inTracks = []
        this.outTracks = []
        this.blockedTrains = []
        this.blocks = []
        this.gizmo = {}
        this.group = new Group
        this.group.name = this.name
        this.group.node = this
        this.group.position.copy(pos)
        geom = Geom.cylinder({height:0.71,radius:0.7,sgmt:32})
        this.center = new Mesh(geom,Materials.node.center)
        this.center.name = this.name + '.center'
        if (!this.fixed)
        {
            this.center.onClick = this.onClickCenter
            this.center.onDoubleClick = this.onDoubleClickCenter
            this.center.onEnter = this.onEnterCenter
            this.center.onLeave = this.onLeaveCenter
            this.center.onDrag = this.onDrag
        }
        geom = new CylinderGeometry(0.5,0.5,1,32)
        geom.translate(0,0,-2)
        geom.rotateX(Math.PI / 2)
        this.outMesh = new Mesh(geom,Materials.node.out)
        this.outMesh.node = this
        this.outMesh.name = this.name + '.out'
        this.outMesh.onDrag = this.onOutDrag
        this.outMesh.onDragDone = this.onDragDone
        this.outMesh.onEnter = this.onEnterOut
        this.outMesh.onLeave = this.onLeaveOut
        this.outMesh.onClick = this.onClickInOut
        geom = new CylinderGeometry(0.5,0.5,1,32)
        geom.translate(0,0,2)
        geom.rotateX(Math.PI / 2)
        this.inMesh = new Mesh(geom,Materials.node.in)
        this.inMesh.node = this
        this.inMesh.name = this.name + '.in'
        this.inMesh.onDrag = this.onInDrag
        this.inMesh.onDragDone = this.onDragDone
        this.inMesh.onEnter = this.onEnterIn
        this.inMesh.onLeave = this.onLeaveIn
        this.inMesh.onClick = this.onClickInOut
        this.group.add(this.center)
        this.group.add(this.inMesh)
        this.group.add(this.outMesh)
        label = world.addLabel({text:this.name,size:0.5,mono:true})
        label.position.z = 0.5
        label.color = 0xffffff
        label.name = this.name + '.label'
        this.center.add(label)
        world.addPickable(this.group)
        world.addObject(this.group)
        if (cfg.dir)
        {
            this.setDir(cfg.dir)
        }
        else
        {
            this.rotate(0)
        }
        this.group.toSave = this.toSave
        this.group.toSave.key = 'nodes'
    }

    Node.prototype["toSave"] = function ()
    {
        return {name:this.name,out:this.outTracks.map(function (tr)
        {
            return tr.name
        }),in:this.inTracks.map(function (tr)
        {
            return tr.name
        }),pos:this.group.position,dir:this.getDir(),fixed:this.fixed}
    }

    Node.prototype["del"] = function ()
    {
        var block, track

        if (this.group)
        {
            world.hideCompass(this)
            post.emit('delNode',this)
            var list = _k_.list(this.allTracks())
            for (var _114_22_ = 0; _114_22_ < list.length; _114_22_++)
            {
                track = list[_114_22_]
                track.del()
            }
            var list1 = _k_.list(this.blocks)
            for (var _117_22_ = 0; _117_22_ < list1.length; _117_22_++)
            {
                block = list1[_117_22_]
                world.removeObject(block)
            }
            world.removeObject(this.group)
            world.removePickable(this.group)
            return delete this.group
        }
    }

    Node.prototype["onDoubleClickCenter"] = function ()
    {
        if (this.inTracks.length === 1 && this.outTracks.length === 1)
        {
            return post.emit('convertNodeToCtrl',this)
        }
    }

    Node.prototype["onClickCenter"] = function ()
    {
        if (Node.skipCenter)
        {
            Node.skipCenter = false
            return
        }
        if (!Node.clickMode)
        {
            if (world.compass.object === this)
            {
                return world.hideCompass(this)
            }
            else
            {
                return world.showCompass(this,this.getPos(),this.getDir())
            }
        }
    }

    Node.prototype["onEnterIn"] = function ()
    {
        return this.inMesh.material = Materials.node.highlightIn
    }

    Node.prototype["onLeaveIn"] = function ()
    {
        return this.inMesh.material = Materials.node.in
    }

    Node.prototype["onEnterOut"] = function ()
    {
        return this.outMesh.material = Materials.node.highlightOut
    }

    Node.prototype["onLeaveOut"] = function ()
    {
        return this.outMesh.material = Materials.node.out
    }

    Node.prototype["onEnterCenter"] = function ()
    {
        this.center.material = Materials.ctrl.highlight
        return post.on('delete',this.del)
    }

    Node.prototype["onLeaveCenter"] = function (hit, nextHit, event)
    {
        if (event.buttons === 0)
        {
            this.center.material = Materials.node.center
        }
        return post.removeListener('delete',this.del)
    }

    Node.prototype["onClickInOut"] = function (hit)
    {
        var _160_31_

        if (Node.clickMode)
        {
            return
        }
        if (Node.skipCenter)
        {
            return
        }
        Node.clickMode = true
        this.clickTracks = ((hit.name != null ? hit.name.endsWith('.in') : undefined) ? this.inTracks : this.outTracks)
        if (!this.dragTrack)
        {
            this.startDrag(this.clickTracks)
        }
        post.on('mouseMove',this.onMouseMove)
        post.on('mouseDown',this.onMouseDown)
        return post.on('mouseUp',this.onMouseUp)
    }

    Node.prototype["onMouseMove"] = function (hit, downHit)
    {
        var hitName

        if (Node.clickMode)
        {
            this.moveInOutDrag(hit,downHit)
        }
        if (hitName = (hit != null ? hit.name : undefined))
        {
            if (!hitName.startsWith(this.name) && !hitName.startsWith(this.dragTrack.node[1].name))
            {
                if (hitName.endsWith('.in') || hitName.endsWith('.out'))
                {
                    console.log(`could connect ${this.name + ((this.clickTracks === this.inTracks ? '.in' : '.out'))} to`,hitName)
                }
            }
        }
    }

    Node.prototype["onMouseDown"] = function (hit, downHit)
    {}

    Node.prototype["onMouseUp"] = function (hit, downHit)
    {
        this.onDragDone(hit,downHit)
        delete this.clickTracks
        post.removeListener('mouseMove',this.onMouseMove)
        post.removeListener('mouseDown',this.onMouseDown)
        post.removeListener('mouseUp',this.onMouseUp)
        Node.skipCenter = true
        return Node.clickMode = false
    }

    Node.prototype["startDrag"] = function (tracks)
    {
        var c1, c2, dir, n1, n2, t

        world.hideCompass(this)
        dir = this.getDir()
        if (tracks === this.inTracks)
        {
            dir.negate()
        }
        n1 = this
        n2 = world.addNode({pos:this.getPos().add(dir)})
        n2.setDir(dir)
        c1 = dir.clone().scale(5).add(n1.getPos())
        c2 = dir.clone().scale(-5).add(n2.getPos())
        t = world.addTrack(n1,n2,[c1,c2])
        t.node[0] = n1
        t.node[1] = n2
        tracks.push(t)
        n2.inTracks.push(t)
        return this.dragTrack = t
    }

    Node.prototype["onInDrag"] = function (hit, downHit)
    {
        if (!this.dragTrack)
        {
            this.startDrag(this.inTracks)
        }
        return this.moveInOutDrag(hit,downHit)
    }

    Node.prototype["onOutDrag"] = function (hit, downHit)
    {
        if (!this.dragTrack)
        {
            this.startDrag(this.outTracks)
        }
        return this.moveInOutDrag(hit,downHit)
    }

    Node.prototype["moveInOutDrag"] = function (hit, downHit)
    {
        var dot, dragNode, plane

        _k_.assert(".", 236, 8, "assert failed!" + " this.dragTrack", this.dragTrack)
        _k_.assert(".", 237, 8, "assert failed!" + " this.dragTrack.node", this.dragTrack.node)
        _k_.assert(".", 238, 8, "assert failed!" + " this.dragTrack.node[1]", this.dragTrack.node[1])
        dragNode = this.dragTrack.node[1]
        plane = new Plane
        plane.setFromNormalAndCoplanarPoint(Vector.unitZ,this.getPos())
        hit.ray.intersectPlane(plane,Vector.tmp)
        Vector.tmp.round()
        if (Vector.tmp.distanceTo(this.getPos()) > 300)
        {
            Vector.tmp.copy(this.getPos().to(Vector.tmp).setLength(300))
            Vector.tmp.add(this.getPos())
        }
        dragNode.group.position.copy(Vector.tmp)
        this.dragTrack.nodeMoved(dragNode)
        Vector.tmp1.copy(this.dragTrack.node[0].trackDir(this.dragTrack))
        this.dragTrack.node[0].getPos(Vector.tmp2)
        this.dragTrack.node[1].getPos(Vector.tmp3)
        Vector.tmp3.sub(Vector.tmp2).normalize()
        dot = Vector.tmp1.dot(Vector.tmp3)
        if (dot <= 0)
        {
            return this.dragTrack.node[1].setDir(Vector.tmp1.negate())
        }
        else if (dot > 0.75)
        {
            return this.dragTrack.node[1].setDir(Vector.tmp1)
        }
        else
        {
            this.dragTrack.node[0].getRight(Vector.tmp2)
            dot = Vector.tmp2.dot(Vector.tmp3)
            if (dot < 0)
            {
                Vector.tmp2.negate()
            }
            return this.dragTrack.node[1].setDir(Vector.tmp2)
        }
    }

    Node.prototype["onDragDone"] = function (hit, downHit)
    {
        var ctrl, hitName, isIn, isOut, n2, on2, t2

        if (hitName = (hit != null ? hit.name : undefined))
        {
            if (this.dragTrack && !hitName.startsWith(this.name) && !hitName.startsWith(this.dragTrack.node[1].name))
            {
                isIn = hitName.endsWith('.in')
                isOut = hitName.endsWith('.out')
                if (isIn || isOut)
                {
                    if (n2 = hit.mesh.node)
                    {
                        t2 = (isIn ? n2.inTracks : n2.outTracks)
                        on2 = this.dragTrack.node[1]
                        on2.removeTrack(this.dragTrack)
                        this.dragTrack.node[1] = n2
                        on2.del()
                        t2.push(this.dragTrack)
                        ctrl = this.dragTrack.ctrls.slice(-1)[0]
                        ctrl.curve.v3.copy(n2.getPos())
                        ctrl.curve.v2.copy(n2.getDir().times(5))
                        if (isIn)
                        {
                            ctrl.curve.v2.negate()
                        }
                        ctrl.curve.v2.add(n2.getPos())
                        this.dragTrack.ctrlMoved()
                    }
                }
            }
        }
        return delete this.dragTrack
    }

    Node.prototype["onDrag"] = function (hit, downHit)
    {
        var plane

        world.hideCompass(this)
        plane = new Plane
        plane.setFromNormalAndCoplanarPoint(Vector.unitZ,this.getPos())
        hit.ray.intersectPlane(plane,Vector.tmp)
        Vector.tmp.round()
        return this.setPos(Vector.tmp)
    }

    Node.prototype["getPos"] = function (p)
    {
        p = (p != null ? p : vec())
        return p.copy(this.group.position)
    }

    Node.prototype["setPos"] = function (point)
    {
        var block, i, track, train

        this.group.position.copy(point)
        var list = _k_.list(this.outTracks)
        for (var _307_18_ = 0; _307_18_ < list.length; _307_18_++)
        {
            track = list[_307_18_]
            track.nodeMoved(this)
        }
        var list1 = _k_.list(this.inTracks)
        for (var _309_18_ = 0; _309_18_ < list1.length; _309_18_++)
        {
            track = list1[_309_18_]
            track.nodeMoved(this)
        }
        for (var _312_17_ = i = 0, _312_21_ = this.blockedTrains.length; (_312_17_ <= _312_21_ ? i < this.blockedTrains.length : i > this.blockedTrains.length); (_312_17_ <= _312_21_ ? ++i : --i))
        {
            block = this.blocks[i]
            train = this.blockedTrains[i]
            train.path.getPoint(block.position,3)
        }
    }

    Node.prototype["onRotate"] = function (hit, downHit, lastHit)
    {
        var angle, plane, point

        point = vec()
        hit.mesh.getWorldPosition(point)
        plane = new Plane
        plane.setFromNormalAndCoplanarPoint(Vector.unitZ,point)
        lastHit.ray.intersectPlane(plane,Vector.tmp)
        hit.ray.intersectPlane(plane,Vector.tmp2)
        Vector.tmp.sub(point)
        Vector.tmp2.sub(point)
        angle = this.getDir().angle(Vector.tmp2) - this.getDir().angle(Vector.tmp)
        if (angle)
        {
            return this.rotate(Math.sign(this.getDir().crossed(this.getUp()).dot(Vector.tmp))* - angle)
        }
    }

    Node.prototype["rotate"] = function (degree)
    {
        return this.setDir(this.getDir().applyQuaternion(Quaternion.axisAngle(this.getUp(),degree)))
    }

    Node.prototype["compassRotated"] = function (dir)
    {
        return this.setDir(dir)
    }

    Node.prototype["getUp"] = function (u)
    {
        u = (u != null ? u : vec())
        return u.copy(Vector.unitZ).applyQuaternion(this.group.quaternion)
    }

    Node.prototype["getDir"] = function (d)
    {
        d = (d != null ? d : vec())
        return d.copy(Vector.unitY).applyQuaternion(this.group.quaternion)
    }

    Node.prototype["getRight"] = function (r)
    {
        r = (r != null ? r : vec())
        return r.copy(Vector.unitX).applyQuaternion(this.group.quaternion)
    }

    Node.prototype["setDir"] = function (dir)
    {
        var quat, track

        quat = Quaternion.unitVectors(Vector.unitY,dir)
        this.group.quaternion.copy(quat)
        var list = _k_.list(this.outTracks)
        for (var _353_18_ = 0; _353_18_ < list.length; _353_18_++)
        {
            track = list[_353_18_]
            track.nodeRotated(this)
        }
        var list1 = _k_.list(this.inTracks)
        for (var _355_18_ = 0; _355_18_ < list1.length; _355_18_++)
        {
            track = list1[_355_18_]
            track.nodeRotated(this)
        }
    }

    Node.prototype["setTrain"] = function (train)
    {
        var block, c1, c2, geom, _389_20_

        if (train === this.train)
        {
            return
        }
        this.train = train
        if (this.train)
        {
            if (!this.nodeBox)
            {
                c1 = new CylinderGeometry(0.25,0.25,1,16)
                c1.rotateX(Math.PI / 2)
                c2 = new CylinderGeometry(0.25,0.25,1.6,16)
                c2.rotateZ(Math.PI / 2)
                geom = Geom.merge(c1,c2)
                this.nodeBox = new Mesh(geom,this.train.cars[0].mesh.material)
                this.group.add(this.nodeBox)
            }
            this.nodeBox.material = this.train.cars[0].mesh.material
            var list = _k_.list(this.blocks)
            for (var _380_22_ = 0; _380_22_ < list.length; _380_22_++)
            {
                block = list[_380_22_]
                block.material = this.nodeBox.material
            }
            this.inMesh.scale.set(1,1,0.72)
            return this.outMesh.scale.set(1,1,0.72)
        }
        else
        {
            this.inMesh.scale.set(1,1,1)
            this.outMesh.scale.set(1,1,1)
            ;(this.nodeBox != null ? this.nodeBox.removeFromParent() : undefined)
            return delete this.nodeBox
        }
    }

    Node.prototype["onRemoveTrain"] = function (train)
    {
        var _393_53_

        console.log('onRemoveTrain',this.name,train.name,(this.train != null ? this.train.name : undefined))
        if (train === this.train)
        {
            return this.setTrain(null)
        }
    }

    Node.prototype["blockTrain"] = function (train)
    {
        var geom, mat, mesh, _1_6_

        if (this.blockedTrains.indexOf(train) >= 0)
        {
            return
        }
        this.blockedTrains.push(train)
        train.block(`node ${this.name} owned by ${(this.train != null ? this.train.name : undefined)}`)
        geom = Geom.merge(new BoxGeometry(0.5,1,0.5),new BoxGeometry(1,0.5,0.5))
        if (this.train)
        {
            mat = this.train.cars[0].mesh.material
        }
        else
        {
            console.log('really?')
            mat = train.cars[0].mesh.material
        }
        mesh = new Mesh(geom,mat)
        train.path.getPoint(mesh.position,3)
        train.path.getTangent(Vector.tmp,3)
        Vector.tmp.add(mesh.position)
        mesh.lookAt(Vector.tmp)
        world.addObject(mesh)
        return this.blocks.push(mesh)
    }

    Node.prototype["unblockTrain"] = function (train)
    {
        var index

        train.unblock()
        if ((index = this.blockedTrains.indexOf(train)) >= 0)
        {
            world.removeObject(this.blocks[index])
            this.blocks.splice(index,1)
            return this.blockedTrains.splice(index,1)
        }
    }

    Node.prototype["unblockAll"] = function ()
    {
        var block, t

        var list = _k_.list(this.blockedTrains)
        for (var _436_14_ = 0; _436_14_ < list.length; _436_14_++)
        {
            t = list[_436_14_]
            t.unblock()
        }
        var list1 = _k_.list(this.blocks)
        for (var _439_18_ = 0; _439_18_ < list1.length; _439_18_++)
        {
            block = list1[_439_18_]
            world.removeObject(block)
        }
        this.setTrain(null)
        this.blockedTrains = []
        return this.blocks = []
    }

    Node.prototype["commonMode"] = function ()
    {
        var inMode, outMode

        inMode = this.tracksMode(this.inTracks)
        outMode = this.tracksMode(this.outTracks)
        return (inMode === outMode ? inMode : 0)
    }

    Node.prototype["tracksMode"] = function (tracks)
    {
        var mode, track, trackMode

        mode = 0
        var list = _k_.list(tracks)
        for (var _461_18_ = 0; _461_18_ < list.length; _461_18_++)
        {
            track = list[_461_18_]
            trackMode = track.modeForNode(this)
            if (mode !== trackMode)
            {
                if (mode === 0)
                {
                    mode = trackMode
                }
                else if (trackMode !== 0)
                {
                    return 0
                }
            }
        }
        return mode
    }

    Node.prototype["trackDir"] = function (track)
    {
        var dir

        dir = this.getDir(Vector.tmp)
        if (_k_.in(track,this.inTracks))
        {
            dir.negate()
        }
        return dir
    }

    Node.prototype["allTracks"] = function ()
    {
        return this.inTracks.concat(this.outTracks)
    }

    Node.prototype["removeTrack"] = function (track)
    {
        var i, tracks

        tracks = this.siblingTracks(track)
        if ((i = tracks.indexOf(track)) >= 0)
        {
            return tracks.splice(i,1)
        }
    }

    Node.prototype["siblingTracks"] = function (track)
    {
        if (_k_.in(track,this.inTracks))
        {
            return this.inTracks
        }
        else if (_k_.in(track,this.outTracks))
        {
            return this.outTracks
        }
        else
        {
            console.log('no siblingTracks')
        }
    }

    Node.prototype["oppositeTracks"] = function (track)
    {
        if (_k_.in(track,this.inTracks))
        {
            return this.outTracks
        }
        else if (_k_.in(track,this.outTracks))
        {
            return this.inTracks
        }
        else
        {
            console.log('no oppositeTracks')
        }
    }

    return Node
})()

module.exports = Node