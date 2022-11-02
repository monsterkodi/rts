// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}}

var ThreeQuaternion

ThreeQuaternion = THREE.Quaternion
class Quaternion extends ThreeQuaternion
{
    static tmp = new Quaternion

    static counter = 0

    constructor (x = 0, y = 0, z = 0, w = 1)
    {
        Quaternion.counter++
        if (x instanceof Vector)
        {
            super(x.x,x.y,x.z,0)
        }
        else if (x instanceof Quaternion || x instanceof THREE.Quaternion)
        {
            super(x.x,x.y,x.z,x.w)
        }
        else if (Array.isArray(w))
        {
            super(w[0],w[1],w[2],w[3])
        }
        else
        {
            super(x,y,z,w)
        }
        if (Number.isNaN(this.x))
        {
            throw new Error
        }
    }

    static unitVectors (n1, n2)
    {
        Quaternion.tmp.setFromUnitVectors(n1,n2)
        return Quaternion.tmp.clone()
    }

    static axisAngle (axis, angle)
    {
        Quaternion.tmp.setFromAxisAngle(axis,deg2rad(angle))
        return Quaternion.tmp.clone()
    }

    rotateAxisAngle (axis, angle)
    {
        this.multiply(Quaternion.axisAngle(axis,angle))
        return this
    }

    clone ()
    {
        return new Quaternion(this)
    }

    copy (q)
    {
        this.x = q.x
        this.y = q.y
        this.z = q.z
        this.w = q.w
        return this
    }

    rounded ()
    {
        var back, backDiff, l, minDist, minQuat, q, quats, up, upDiff

        minDist = 1000
        minQuat = null
        up = this.rotate(Vector.unitY)
        back = this.rotate(Vector.unitZ)
        quats = [Quaternion.XupY(Quaternion.XupZ,Quaternion.XdownY,Quaternion.XdownZ,Quaternion.YupX,Quaternion.YupZ,Quaternion.YdownX,Quaternion.YdownZ,Quaternion.ZupX,Quaternion.ZupY,Quaternion.ZdownX,Quaternion.ZdownY,Quaternion.minusXupY,Quaternion.minusXupZ,Quaternion.minusXdownY,Quaternion.minusXdownZ,Quaternion.minusYupX,Quaternion.minusYupZ,Quaternion.minusYdownX,Quaternion.minusYdownZ,Quaternion.minusZupX,Quaternion.minusZupY,Quaternion.minusZdownX,Quaternion.minusZdownY)]
        var list = _k_.list(quats)
        for (var _84_14_ = 0; _84_14_ < list.length; _84_14_++)
        {
            q = list[_84_14_]
            upDiff = 1 - up.dot(q.rotate(Vector.unitY))
            backDiff = 1 - back.dot(q.rotate(Vector.unitZ))
            l = upDiff + backDiff
            if (l < minDist)
            {
                minDist = l
                minQuat = q
                if (l < 0.0001)
                {
                    break
                }
            }
        }
        return minQuat
    }

    round ()
    {
        return this.clone(this.normalize().rounded())
    }

    euler ()
    {
        return [rad2deg(Math.atan2(2 * (this.w * this.x + this.y * this.z),1 - 2 * (this.x * this.x + this.y * this.y))),rad2deg(Math.asin(2 * (this.w * this.y - this.z * this.x))),rad2deg(Math.atan2(2 * (this.w * this.z + this.x * this.y),1 - 2 * (this.y * this.y + this.z * this.z)))]
    }

    add (quat)
    {
        this.w += quat.w
        this.x += quat.x
        this.y += quat.y
        this.z += quat.z
        return this
    }

    sub (quat)
    {
        this.w -= quat.w
        this.x -= quat.x
        this.y -= quat.y
        this.z -= quat.z
        return this
    }

    minus (quat)
    {
        return this.clone().sub(quat)
    }

    dot (q)
    {
        return this.x * q.x + this.y * q.y + this.z * q.z + this.w * q.w
    }

    rotate (v)
    {
        return vec(v).applyQuaternion(this)
    }

    normalize ()
    {
        var l

        l = Math.sqrt(this.w * this.w + this.x * this.x + this.y * this.y + this.z * this.z)
        if (l !== 0.0)
        {
            this.w /= l
            this.x /= l
            this.y /= l
            this.z /= l
        }
        return this
    }

    invert ()
    {
        var l

        l = Math.sqrt(this.w * this.w + this.x * this.x + this.y * this.y + this.z * this.z)
        if (l !== 0.0)
        {
            this.w /= l
            this.x = -this.x / l
            this.y = -this.y / l
            this.z = -this.z / l
        }
        return this
    }

    isZero ()
    {
        return (this.x === this.y && (this.y === this.z && this.z === 0)) && this.w === 1
    }

    reset ()
    {
        this.x = this.y = this.z = 0
        this.w = 1
        return this
    }

    conjugate ()
    {
        this.x = -this.x
        this.y = -this.y
        this.z = -this.z
        return this
    }

    getNormal ()
    {
        return this.clone().normalize()
    }

    getConjugate ()
    {
        return this.clone().conjugate()
    }

    getInverse ()
    {
        return this.clone().invert()
    }

    neg ()
    {
        return new Quaternion(-this.w,-this.x,-this.y,-this.z)
    }

    vector ()
    {
        return new Vector(this.x,this.y,this.z)
    }

    length ()
    {
        return Math.sqrt(this.w * this.w + this.x * this.x + this.y * this.y + this.z * this.z)
    }

    eql (q)
    {
        return this.w === q.w && (this.x = q.x && this.y === q.y && this.z === q.z)
    }

    mul (quatOrScalar)
    {
        var A, B, C, D, E, f, F, G, H, quat

        if (quatOrScalar instanceof Quaternion)
        {
            quat = quatOrScalar
            A = (this.w + this.x) * (quat.w + quat.x)
            B = (this.z - this.y) * (quat.y - quat.z)
            C = (this.w - this.x) * (quat.y + quat.z)
            D = (this.y + this.z) * (quat.w - quat.x)
            E = (this.x + this.z) * (quat.x + quat.y)
            F = (this.x - this.z) * (quat.x - quat.y)
            G = (this.w + this.y) * (quat.w - quat.z)
            H = (this.w - this.y) * (quat.w + quat.z)
            return new Quaternion(B + (-E - F + G + H) / 2,A - (E + F + G + H) / 2)
        }
        else
        {
            f = parseFloat(quatOrScalar)
            return new Quaternion(this.w * f,this.x * f,this.y * f,this.z * f)
        }
    }

    slerp (quat, t)
    {
        var cosom, omega, scale0, scale1, sinom, to1

        to1 = [0,0,0,0]
        cosom = this.x * quat.x + this.y * quat.y + this.z * quat.z + this.w * quat.w
        if (cosom < 0)
        {
            cosom = -cosom
            to1[0] = -quat.x
            to1[1] = -quat.y
            to1[2] = -quat.z
            to1[3] = -quat.w
        }
        else
        {
            to1[0] = quat.x
            to1[1] = quat.y
            to1[2] = quat.z
            to1[3] = quat.w
        }
        if ((1.0 - cosom) > 0.001)
        {
            omega = Math.acos(cosom)
            sinom = Math.sin(omega)
            scale0 = Math.sin((1.0 - t) * omega) / sinom
            scale1 = Math.sin(t * omega) / sinom
        }
        else
        {
            scale0 = 1.0 - t
            scale1 = t
        }
        return new Quaternion(scale0 * this.w + scale1 * to1[3],scale0 * this.x + scale1 * to1[0])
    }

    static rotationAroundVector (theta, x, y, z)
    {
        var s, t, v

        v = new Vector(x,y,z)
        v.normalize()
        t = deg2rad(theta) / 2.0
        s = Math.sin(t)
        return (new Quaternion(Math.cos(t),v.x * s,v.y * s,v.z * s)).normalize()
    }

    static rotationFromEuler (x, y, z)
    {
        var q

        x = deg2rad(x)
        y = deg2rad(y)
        z = deg2rad(z)
        q = new Quaternion(Math.cos(x / 2) * Math.cos(y / 2) * Math.cos(z / 2) + Math.sin(x / 2) * Math.sin(y / 2) * Math.sin(z / 2),Math.sin(x / 2) * Math.cos(y / 2) * Math.cos(z / 2) - Math.cos(x / 2) * Math.sin(y / 2) * Math.sin(z / 2))
        return q.normalize()
    }
}

Quaternion.rot_0 = new Quaternion()
Quaternion.rot_90_X = Quaternion.rotationAroundVector(90,Vector.unitX)
Quaternion.rot_90_Y = Quaternion.rotationAroundVector(90,Vector.unitY)
Quaternion.rot_90_Z = Quaternion.rotationAroundVector(90,Vector.unitZ)
Quaternion.rot_180_X = Quaternion.rotationAroundVector(180,Vector.unitX)
Quaternion.rot_180_Y = Quaternion.rotationAroundVector(180,Vector.unitY)
Quaternion.rot_180_Z = Quaternion.rotationAroundVector(180,Vector.unitZ)
Quaternion.rot_270_X = Quaternion.rotationAroundVector(270,Vector.unitX)
Quaternion.rot_270_Y = Quaternion.rotationAroundVector(270,Vector.unitY)
Quaternion.rot_270_Z = Quaternion.rotationAroundVector(270,Vector.unitZ)
Quaternion.minusXupY = Quaternion.rot_270_Y
Quaternion.minusXupZ = Quaternion.rot_90_X.mul(Quaternion.rot_270_Y)
Quaternion.minusXdownY = Quaternion.rot_180_X.mul(Quaternion.rot_270_Y)
Quaternion.minusXdownZ = Quaternion.rot_270_X.mul(Quaternion.rot_270_Y)
Quaternion.minusYupX = Quaternion.rot_90_Y.mul(Quaternion.rot_90_X)
Quaternion.minusYupZ = Quaternion.rot_90_X
Quaternion.minusYdownX = Quaternion.rot_270_Y.mul(Quaternion.rot_90_X)
Quaternion.minusYdownZ = Quaternion.rot_180_Y.mul(Quaternion.rot_90_X)
Quaternion.ZupX = Quaternion.rot_270_Z
Quaternion.ZupY = Quaternion.rot_0
Quaternion.ZdownX = Quaternion.rot_90_Z
Quaternion.ZdownY = Quaternion.rot_180_Z
Quaternion.XupY = Quaternion.rot_90_Y
Quaternion.XupZ = Quaternion.rot_90_X.mul(Quaternion.rot_90_Y)
Quaternion.XdownY = Quaternion.rot_180_X.mul(Quaternion.rot_90_Y)
Quaternion.XdownZ = Quaternion.rot_270_X.mul(Quaternion.rot_90_Y)
Quaternion.YupX = Quaternion.rot_270_Y.mul(Quaternion.rot_270_X)
Quaternion.YupZ = Quaternion.rot_180_Y.mul(Quaternion.rot_270_X)
Quaternion.YdownX = Quaternion.rot_90_Y.mul(Quaternion.rot_270_X)
Quaternion.YdownZ = Quaternion.rot_270_X
Quaternion.minusZupX = Quaternion.rot_90_Z.mul(Quaternion.rot_180_X)
Quaternion.minusZupY = Quaternion.rot_180_Z.mul(Quaternion.rot_180_X)
Quaternion.minusZdownX = Quaternion.rot_270_Z.mul(Quaternion.rot_180_X)
Quaternion.minusZdownY = Quaternion.rot_180_X
Quaternion.rot_0.name = 'rot_0'
Quaternion.rot_90_X.name = 'rot_90_X'
Quaternion.rot_90_Y.name = 'rot_90_Y'
Quaternion.rot_90_Z.name = 'rot_90_Z'
Quaternion.rot_180_X.name = 'rot_180_X'
Quaternion.rot_180_Y.name = 'rot_180_Y'
Quaternion.rot_180_Z.name = 'rot_180_Z'
Quaternion.rot_270_X.name = 'rot_270_X'
Quaternion.rot_270_Y.name = 'rot_270_Y'
Quaternion.rot_270_Z.name = 'rot_270_Z'
Quaternion.XupY.name = 'XupY'
Quaternion.XupZ.name = 'XupZ'
Quaternion.XdownY.name = 'XdownY'
Quaternion.XdownZ.name = 'XdownZ'
Quaternion.YupX.name = 'YupX'
Quaternion.YupZ.name = 'YupZ'
Quaternion.YdownX.name = 'YdownX'
Quaternion.YdownZ.name = 'YdownZ'
Quaternion.ZupX.name = 'ZupX'
Quaternion.ZupY.name = 'ZupY'
Quaternion.ZdownX.name = 'ZdownX'
Quaternion.ZdownY.name = 'ZdownY'
Quaternion.minusXupY.name = 'minusXupY'
Quaternion.minusXupZ.name = 'minusXupZ'
Quaternion.minusXdownY.name = 'minusXdownY'
Quaternion.minusXdownZ.name = 'minusXdownZ'
Quaternion.minusYupX.name = 'minusYupX'
Quaternion.minusYupZ.name = 'minusYupZ'
Quaternion.minusYdownX.name = 'minusYdownX'
Quaternion.minusYdownZ.name = 'minusYdownZ'
Quaternion.minusZupX.name = 'minusZupX'
Quaternion.minusZupY.name = 'minusZupY'
Quaternion.minusZdownX.name = 'minusZdownX'
Quaternion.minusZdownY.name = 'minusZdownY'
module.exports = Quaternion