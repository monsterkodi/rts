// monsterkodi/kode 0.243.0

var _k_

class Boxes
{
    constructor (scene, maxBoxes = 1000, geom = Geometry.cornerBox(), material, shadows = true)
    {
        this.maxBoxes = maxBoxes
    
        this.boxes = []
        this.sz = vec()
        material = new THREE.MeshStandardMaterial({color:0xffffff,metalness:0.3,roughness:0.3})
        this.cluster = new THREE.InstancedMesh(geom,material,this.maxBoxes)
        if (shadows)
        {
            this.cluster.receiveShadow = true
            this.cluster.castShadow = true
        }
        scene.add(this.cluster)
    }

    numBoxes ()
    {
        return this.boxes.length
    }

    lastBox ()
    {
        return this.boxes[this.lastIndex()]
    }

    lastIndex ()
    {
        return this.numBoxes() - 1
    }

    setDir (box, dir)
    {
        return this.setRot(box,Quaternion.unitVectors(Vector.unitZ,dir))
    }

    setPos (box, pos)
    {
        var mat

        mat = new THREE.Matrix4
        this.cluster.getMatrixAt(box.index,mat)
        mat.setPosition(pos)
        this.cluster.setMatrixAt(box.index,mat)
        return this.cluster.instanceMatrix.needsUpdate = true
    }

    setRot (box, rot)
    {
        var mat

        mat = new THREE.Matrix4
        this.cluster.getMatrixAt(box.index,mat)
        mat.makeRotationFromQuaternion(rot)
        return this.cluster.setMatrixAt(box.index,mat)
    }

    setColor (box, color)
    {
        this.cluster.setColorAt(box.index,color)
        return this.cluster.instanceColor.needsUpdate = true
    }

    setSize (box, size)
    {
        var mat, pos, rot, scale

        this.sz.x = size
        this.sz.y = size
        this.sz.z = size
        mat = new THREE.Matrix4
        this.cluster.getMatrixAt(box.index,mat)
        pos = new THREE.Vector3
        rot = new THREE.Quaternion
        scale = new THREE.Vector3
        mat.decompose(pos,rot,scale)
        mat.compose(pos,rot,this.sz)
        this.cluster.setMatrixAt(box.index,mat)
        return this.cluster.instanceMatrix.needsUpdate = true
    }

    pos (box, pos = vec())
    {
        var mat

        mat = new THREE.Matrix4
        this.cluster.getMatrixAt(box.index,mat)
        pos = new THREE.Vector3
        pos.setFromMatrixPosition(mat)
        return pos
    }

    rot (box, rot = quat())
    {
        var mat, pos, scale

        mat = new THREE.Matrix4
        this.cluster.getMatrixAt(box.index,mat)
        pos = new THREE.Vector3
        scale = new THREE.Vector3
        mat.decompose(pos,rot,scale)
        return rot
    }

    size (box, szv = vec())
    {
        var mat, pos, rot

        mat = new THREE.Matrix4
        this.cluster.getMatrixAt(box.index,mat)
        pos = new THREE.Vector3
        rot = new THREE.Quaternion
        mat.decompose(pos,rot,szv)
        return szv
    }

    color (box, color = new THREE.Color())
    {
        this.cluster.getColorAt(box.index,color)
        return color
    }

    add (cfg)
    {
        var box, _87_33_, _89_18_, _91_23_

        box = {index:this.numBoxes()}
        this.boxes.push(box)
        this.cluster.count = this.numBoxes()
        if (cfg.pos)
        {
            this.setPos(box,cfg.pos)
        }
        else
        {
            this.sz.set(0,0,0)
            this.setPos(box,this.sz)
        }
        this.setColor(box,((_87_33_=cfg.color) != null ? _87_33_ : Color.white))
        if ((cfg.dir != null))
        {
            this.setDir(box,cfg.dir)
        }
        else if ((cfg.rot != null))
        {
            this.setRot(box,cfg.rot)
        }
        else
        {
            this.setRot(box,quat())
        }
        return box
    }

    remove ()
    {
        var _102_16_

        this.boxes = []
        this.cluster.dispose()
        ;(this.cluster != null ? this.cluster.parent.remove(this.cluster) : undefined)
        return delete this.cluster
    }

    clear ()
    {
        this.boxes = []
        return this.cluster.count = this.boxes.length
    }

    del (box)
    {
        var color, lastBox, pos, rot, size

        if (box.index < this.lastIndex())
        {
            lastBox = this.boxes.pop()
            pos = this.pos(lastBox)
            rot = this.rot(lastBox)
            size = this.size(lastBox)
            color = this.color(lastBox)
            this.boxes[box.index] = lastBox
            lastBox.index = box.index
            this.setPos(lastBox,pos)
            this.setRot(lastBox,rot)
            this.setSize(lastBox,size)
            this.setColor(lastBox,color)
        }
        else if (box.index === this.lastIndex())
        {
            lastBox = this.boxes.pop()
        }
        else
        {
            console.log(`Boxes.del dafuk? ${box.index} ${this.lastIndex()}`)
        }
        return this.cluster.count = this.boxes.length
    }

    render ()
    {}
}

module.exports = Boxes