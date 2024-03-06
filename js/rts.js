// monsterkodi/kode 0.257.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}, clamp: function (l,h,v) { var ll = Math.min(l,h), hh = Math.max(l,h); if (!_k_.isNum(v)) { v = ll }; if (v < ll) { v = ll }; if (v > hh) { v = hh }; if (!_k_.isNum(v)) { v = ll }; return v }, isFunc: function (o) {return typeof o === 'function'}, isNum: function (o) {return !isNaN(o) && !isNaN(parseFloat(o)) && (isFinite(o) || o === Infinity || o === -Infinity)}}

var BloomPass, Camera, Config, CurveCtrl, Debug, deg2rad, e, EffectComposer, elem, expose, FPS, GridHelper, Info, kxk, Map, Menu, Node, post, prefs, rad2deg, randInt, randIntRange, randRange, RenderPass, setShadow, ShaderPass, SimplexNoise, Sound, SSAOPass, stopEvent, Text, tmpMatrix, UnrealBloomPass, World, _

kxk = require('kxk')
_ = require('kxk')._
clamp = require('kxk').clamp
deg2rad = require('kxk').deg2rad
elem = require('kxk').elem
first = require('kxk').first
last = require('kxk').last
post = require('kxk').post
prefs = require('kxk').prefs
rad2deg = require('kxk').rad2deg
randInt = require('kxk').randInt
randIntRange = require('kxk').randIntRange
randRange = require('kxk').randRange
stopEvent = require('kxk').stopEvent

window.$ = kxk.$
window._ = _
window.post = post
window.prefs = prefs
window.randInt = randInt
window.randIntRange = randIntRange
window.randRange = randRange
window.deg2rad = deg2rad
window.rad2deg = rad2deg
window.stopEvent = stopEvent
window.first = first
window.last = last
window.elem = elem
window.THREE = require('three')
expose = `Ray
Mesh
Line3
Color
Group
Plane
Matrix3
Matrix4
Sphere
CurvePath
BoxGeometry
PlaneGeometry
SphereGeometry
CircleGeometry
CylinderGeometry
LineSegments
QuadraticBezierCurve3
CubicBezierCurve3`
var list = _k_.list(expose.split('\n'))
for (var _50_6_ = 0; _50_6_ < list.length; _50_6_++)
{
    e = list[_50_6_]
    window[e] = THREE[e]
}
require('three/examples/js/shaders/CopyShader')
require('three/examples/js/shaders/SSAOShader')
require('three/examples/js/shaders/ConvolutionShader')
require('three/examples/js/shaders/LuminosityHighPassShader')
require('three/examples/js/postprocessing/Pass')
require('three/examples/js/postprocessing/ShaderPass')
require('three/examples/js/postprocessing/EffectComposer')
require('three/examples/js/postprocessing/RenderPass')
require('three/examples/js/postprocessing/SSAOPass')
require('three/examples/js/postprocessing/UnrealBloomPass')
require('three/examples/js/postprocessing/BloomPass')
require('three/examples/js/math/SimplexNoise')
Text = require('troika-three-text').Text

window.Text = Text
EffectComposer = THREE.EffectComposer
RenderPass = THREE.RenderPass
UnrealBloomPass = THREE.UnrealBloomPass
SSAOPass = THREE.SSAOPass
SimplexNoise = THREE.SimplexNoise
BloomPass = THREE.BloomPass
ShaderPass = THREE.ShaderPass


setShadow = function ()
{
    return this.castShadow = this.receiveShadow = true
}
setShadow.bind(window.Mesh)
window.Mesh.prototype.setShadow = setShadow
window.BufferGeometry = THREE.BufferGeometry
window.BufferAttribute = THREE.BufferAttribute
window.Vector = require('./lib/vector')
window.Quaternion = require('./lib/quaternion')
window.Colors = require('./const/colors')
window.Materials = require('./const/materials')
window.Geom = require('./const/geometry')

window.playSound = function (o, n, c)
{
    return rts.sound.play(o,n,c)
}
FPS = require('./lib/fps')
Info = require('./lib/info')
Debug = require('./lib/debug')
Sound = require('./lib/sound')
GridHelper = require('./lib/gridhelper')
Config = require('./const/config')
Menu = require('./menu/menu')
World = require('./world/world')
Map = require('./world/map')
Camera = require('./lib/camera')
Node = require('./track/node')
CurveCtrl = require('./track/curvectrl')
tmpMatrix = new THREE.Matrix3
class RTS
{
    constructor (view)
    {
        var cam, canvas, _139_74_

        this.view = view
    
        this.onDblClick = this.onDblClick.bind(this)
        this.onClick = this.onClick.bind(this)
        this.onMouseMove = this.onMouseMove.bind(this)
        this.onMouseUp = this.onMouseUp.bind(this)
        this.onMouseDown = this.onMouseDown.bind(this)
        this.animationStep = this.animationStep.bind(this)
        this.decrBrightness = this.decrBrightness.bind(this)
        this.incrBrightness = this.incrBrightness.bind(this)
        this.resetBrightness = this.resetBrightness.bind(this)
        this.getBrightness = this.getBrightness.bind(this)
        this.setBrightness = this.setBrightness.bind(this)
        window.rts = this
        window.config = Config.default
        this.sound = new Sound
        this.fps = new FPS
        this.paused = false
        this.animations = []
        this.worldAnimations = []
        this.renderer = new THREE.WebGLRenderer()
        this.renderer.setPixelRatio(window.devicePixelRatio)
        this.renderer.setSize(this.view.clientWidth,this.view.clientHeight)
        this.renderer.setClearColor(Colors.menu.background)
        this.renderer.shadowMap.enabled = true
        this.renderer.shadowMap.type = THREE.PCFSoftShadowMap
        this.renderer.info.autoReset = false
        this.camera = new Camera({view:this.view})
        this.scene = new THREE.Scene()
        canvas = this.renderer.domElement
        this.initComposer()
        this.view.appendChild(this.renderer.domElement)
        this.lightIntensityAmbient = 0.2
        this.lightIntensityPlayer = 0.2
        this.lightIntensityShadow = 0.5
        this.lightAmbient = new THREE.AmbientLight(0xffffff,this.lightIntensityAmbient)
        this.scene.add(this.lightAmbient)
        this.lightPlayer = new THREE.PointLight(0xffffff,this.lightIntensityPlayer)
        if ((this.player != null))
        {
            this.lightPlayer.position.copy(this.player.camera.getPosition())
        }
        this.lightPlayer.position.copy(this.camera.position)
        this.scene.add(this.lightPlayer)
        this.lightShadow = new THREE.DirectionalLight(0xffffff,this.lightIntensityShadow)
        this.lightShadow.castShadow = true
        this.lightShadow.position.set(100,0,100)
        this.lightShadow.target.position.set(0,0,0)
        this.lightShadow.shadow.mapSize.width = 2 * 2048
        this.lightShadow.shadow.mapSize.height = 2 * 2048
        this.lightShadow.shadow.camera.near = 0.5
        this.lightShadow.shadow.camera.far = 500
        this.lightShadow.shadow.camera.left = -50
        this.lightShadow.shadow.camera.right = 50
        this.lightShadow.shadow.camera.top = 50
        this.lightShadow.shadow.camera.bottom = -50
        this.scene.add(this.lightShadow)
        this.lightShadowHelper = new THREE.DirectionalLightHelper(this.lightShadow,5,new THREE.Color(0xffff00))
        this.lightShadowHelper.visible = false
        this.scene.add(this.lightShadowHelper)
        this.shadowCameraHelper = new THREE.CameraHelper(this.lightShadow.shadow.camera)
        this.shadowCameraHelper.visible = false
        this.scene.add(this.shadowCameraHelper)
        this.setBrightness(prefs.get('brightness',1.0))
        this.gridHelper = new GridHelper()
        this.gridHelper.visible = prefs.get('grid',false)
        this.scene.add(this.gridHelper)
        this.axesHelper = new THREE.AxesHelper(10)
        this.axesHelper.position.copy(this.camera.center)
        this.axesHelper.visible = false
        this.axesHelper.material.depthWrite = false
        this.axesHelper.material.depthTest = false
        this.axesHelper.material.depthFunc = THREE.NeverDepth
        this.scene.add(this.axesHelper)
        this.arrowHelper = new THREE.ArrowHelper(vec(0,0,1),this.camera.center,1,0x8888ff)
        this.arrowHelper.visible = false
        this.scene.add(this.arrowHelper)
        this.centerHelper = new THREE.ArrowHelper(vec(0,0,1),this.camera.center,5,0xff8888)
        this.centerHelper.visible = false
        this.scene.add(this.centerHelper)
        this.mouse = vec()
        this.downPos = vec()
        this.raycaster = new THREE.Raycaster()
        new Map(this.scene)
        if (cam = prefs.get('camera'))
        {
            world.setCamera(cam)
        }
        this.debug = new Debug
        if (!prefs.get('debug'))
        {
            this.debug.hide()
        }
        this.menu = new Menu
        document.addEventListener('mousemove',this.onMouseMove)
        document.addEventListener('mousedown',this.onMouseDown)
        document.addEventListener('mouseup',this.onMouseUp)
        document.addEventListener('dblclick',this.onDblClick)
        this.lastAnimationTime = window.performance.now()
        if (!prefs.get('save'))
        {
            world.create()
        }
        else
        {
            post.emit('load')
        }
        this.animationStep()
        this.paused = prefs.get('paused',false)
    }

    initComposer ()
    {
        var radius, renderTarget, resolution, size, strength, threshold, unrealBloomPass, vh, vw

        size = this.renderer.getDrawingBufferSize(new THREE.Vector2())
        renderTarget = new THREE.WebGLRenderTarget(size.width,size.height,{samples:4})
        vw = this.view.clientWidth
        vh = this.view.clientHeight
        this.composer = new EffectComposer(this.renderer,renderTarget)
        this.composer.setPixelRatio(window.devicePixelRatio)
        this.composer.setSize(vw,vh)
        this.composer.addPass(new RenderPass(this.scene,this.camera))
        resolution = new THREE.Vector2(vw,vh)
        strength = 0.8
        threshold = 0.8
        radius = 0
        unrealBloomPass = new UnrealBloomPass(resolution,strength,radius,threshold)
        return this.composer.addPass(unrealBloomPass)
    }

    setBrightness (brightness)
    {
        var c

        this.brightness = brightness
    
        this.brightness = _k_.clamp(0,1,this.brightness)
        c = Colors.clear.clone()
        c.multiplyScalar(this.brightness)
        this.renderer.setClearColor(c)
        this.lightAmbient.intensity = this.lightIntensityAmbient * this.brightness
        this.lightShadow.intensity = this.lightIntensityShadow * this.brightness
        this.lightPlayer.intensity = this.lightIntensityPlayer * this.brightness
        post.emit('brightness',this.brightness)
        return prefs.set('brightness',this.brightness)
    }

    getBrightness ()
    {
        return this.brightness
    }

    resetBrightness ()
    {
        return this.setBrightness(1)
    }

    incrBrightness ()
    {
        return this.setBrightness(this.getBrightness() + 0.1)
    }

    decrBrightness ()
    {
        return this.setBrightness(this.getBrightness() - 0.1)
    }

    animate (func)
    {
        return this.animations.push(func)
    }

    deanimate (func)
    {
        var index

        if ((index = this.animations.indexOf(func)) >= 0)
        {
            return this.animations.splice(index,1)
        }
    }

    animateWorld (func)
    {
        return this.worldAnimations.push(func)
    }

    togglePause ()
    {
        this.paused = !this.paused
        prefs.set('paused',this.paused)
        return post.emit('pause',this.paused)
    }

    animationStep ()
    {
        var angle, animation, delta, now, oldAnimations, oldWorldAnimations

        now = window.performance.now()
        delta = (now - this.lastAnimationTime) * 0.001
        this.lastAnimationTime = now
        oldAnimations = this.animations.clone()
        this.animations = []
        var list1 = _k_.list(oldAnimations)
        for (var _315_22_ = 0; _315_22_ < list1.length; _315_22_++)
        {
            animation = list1[_315_22_]
            animation(delta)
        }
        this.menu.animate(delta)
        if (!this.paused)
        {
            world.animate(delta)
            angle = -delta * 0.5 * world.speed
            this.lightShadow.position.applyQuaternion(Quaternion.axisAngle(Vector.unitZ,angle))
            this.lightShadowHelper.update()
            oldWorldAnimations = this.worldAnimations.clone()
            this.worldAnimations = []
            var list2 = _k_.list(oldWorldAnimations)
            for (var _330_26_ = 0; _330_26_ < list2.length; _330_26_++)
            {
                animation = list2[_330_26_]
                animation(delta * world.speed)
            }
        }
        this.render()
        return window.requestAnimationFrame(this.animationStep)
    }

    onMouseDown (event)
    {
        var _352_32_, _352_41_

        this.calcMouse(event)
        this.downPos.copy(this.mouse)
        this.camMove = event.button !== 1
        if (this.downHit = this.castRay())
        {
            if (event.buttons === 1)
            {
                if (_k_.isFunc(((_352_32_=this.downHit.mesh) != null ? (_352_41_=_352_32_.handler) != null ? _352_41_.onMouseDown : undefined : undefined)))
                {
                    this.downHit.mesh.handler.onMouseDown(this.downHit,event)
                }
            }
        }
        return post.emit('mouseDown',this.downHit,event)
    }

    onMouseUp (event)
    {
        var hit, moved, _363_19_, _363_25_, _365_24_, _365_30_, _365_39_, _368_19_, _368_25_, _368_34_

        this.calcMouse(event)
        hit = this.castRay()
        if (_k_.isFunc(((_363_19_=this.downHit) != null ? (_363_25_=_363_19_.mesh) != null ? _363_25_.onDragDone : undefined : undefined)))
        {
            this.downHit.mesh.onDragDone(hit,this.downHit)
        }
        else if (_k_.isFunc(((_365_24_=this.downHit) != null ? (_365_30_=_365_24_.mesh) != null ? (_365_39_=_365_30_.handler) != null ? _365_39_.onDragDone : undefined : undefined : undefined)))
        {
            this.downHit.mesh.handler.onDragDone(hit,this.downHit)
        }
        if (_k_.isFunc(((_368_19_=this.downHit) != null ? (_368_25_=_368_19_.mesh) != null ? (_368_34_=_368_25_.handler) != null ? _368_34_.onMouseUp : undefined : undefined : undefined)))
        {
            this.downHit.mesh.handler.onMouseUp(hit,this.downHit)
        }
        post.emit('mouseUp',hit,this.downHit)
        moved = this.downPos.dist(this.mouse)
        if (moved < 0.001)
        {
            this.onClick(event)
        }
        if (moved < 0.01)
        {
            if (event.button === 2)
            {
                this.focusOnHit()
            }
        }
        Node.skipCenter = false
        return delete this.camMove
    }

    onMouseMove (event)
    {
        var hit, _392_27_, _392_33_, _394_32_, _394_38_, _394_47_, _399_23_, _400_27_, _400_33_, _402_32_, _402_38_, _402_47_, _404_27_, _406_32_, _406_41_

        this.calcMouse(event)
        if (hit = this.castRay())
        {
            if (event.buttons === 1)
            {
                if (_k_.isFunc(((_392_27_=this.downHit) != null ? (_392_33_=_392_27_.mesh) != null ? _392_33_.onDrag : undefined : undefined)))
                {
                    this.downHit.mesh.onDrag(hit,this.downHit,this.lastHit)
                }
                else if (_k_.isFunc(((_394_32_=this.downHit) != null ? (_394_38_=_394_32_.mesh) != null ? (_394_47_=_394_38_.handler) != null ? _394_47_.onDrag : undefined : undefined : undefined)))
                {
                    this.downHit.mesh.handler.onDrag(hit,this.downHit,this.lastHit)
                }
            }
            post.emit('mouseMove',hit,this.downHit,this.lastHit)
            if ((this.lastHit != null ? this.lastHit.mesh : undefined) !== hit.mesh)
            {
                if (_k_.isFunc(((_400_27_=this.lastHit) != null ? (_400_33_=_400_27_.mesh) != null ? _400_33_.onLeave : undefined : undefined)))
                {
                    this.lastHit.mesh.onLeave(this.lastHit,hit,event)
                }
                else if (_k_.isFunc(((_402_32_=this.lastHit) != null ? (_402_38_=_402_32_.mesh) != null ? (_402_47_=_402_38_.handler) != null ? _402_47_.onLeave : undefined : undefined : undefined)))
                {
                    this.lastHit.mesh.handler.onLeave(this.lastHit,hit,event)
                }
                if (_k_.isFunc((hit.mesh != null ? hit.mesh.onEnter : undefined)))
                {
                    hit.mesh.onEnter(hit,this.lastHit,event)
                }
                else if (_k_.isFunc(((_406_32_=hit.mesh) != null ? (_406_41_=_406_32_.handler) != null ? _406_41_.onEnter : undefined : undefined)))
                {
                    hit.mesh.handler.onEnter(hit,this.lastHit,event)
                }
            }
            return this.lastHit = hit
        }
    }

    onClick (event)
    {
        var hit, _414_23_, _417_28_, _417_37_

        if (hit = this.castRay())
        {
            if (_k_.isFunc((hit.mesh != null ? hit.mesh.onClick : undefined)))
            {
                if (this.downHit.mesh === hit.mesh)
                {
                    hit.mesh.onClick(hit,event)
                }
            }
            else if (_k_.isFunc(((_417_28_=hit.mesh) != null ? (_417_37_=_417_28_.handler) != null ? _417_37_.onClick : undefined : undefined)))
            {
                if (this.downHit.mesh === hit.mesh)
                {
                    hit.mesh.handler.onClick(hit,event)
                }
            }
            else if (hit.name === 'floor')
            {
                world.hideCompass()
                CurveCtrl.deactivateAll()
            }
            else
            {
                console.log('unhandled click',hit)
            }
            return post.emit('mouseClick',hit,event)
        }
    }

    onDblClick (event)
    {
        var hit, _432_23_, _434_28_, _434_37_

        if (hit = this.castRay())
        {
            if (_k_.isFunc((hit.mesh != null ? hit.mesh.onDoubleClick : undefined)))
            {
                return hit.mesh.onDoubleClick(hit)
            }
            else if (_k_.isFunc(((_434_28_=hit.mesh) != null ? (_434_37_=_434_28_.handler) != null ? _434_37_.onDoubleClick : undefined : undefined)))
            {
                return hit.mesh.handler.onDoubleClick(hit)
            }
            else
            {
                console.log('unhandled doubleClick',hit)
            }
        }
    }

    calcMouse (event)
    {
        var br

        br = this.view.getBoundingClientRect()
        this.mouse.x = ((event.clientX - 6) / br.width) * 2 - 1
        this.mouse.y = -((event.clientY - br.top) / br.height) * 2 + 1
        return this.mouse
    }

    focusOnHit ()
    {
        var hit

        if (hit = this.castRay())
        {
            this.camera.fadeToPoint(hit.point)
            this.centerHelper.setDirection(hit.norm)
            this.centerHelper.position.copy(hit.point)
            return this.axesHelper.position.copy(hit.point)
        }
    }

    castRay ()
    {
        var info, intersect, intersects, norm, point, ray

        this.raycaster.setFromCamera(this.mouse,this.camera)
        intersects = this.raycaster.intersectObjects(world.pickables,true)
        intersects = intersects.filter(function (i)
        {
            return i.object.noHitTest !== true
        })
        intersect = intersects[0]
        if (!intersect)
        {
            return
        }
        point = intersect.point
        norm = intersect.face.normal.clone()
        tmpMatrix.getNormalMatrix(intersect.object.matrixWorld)
        norm.applyMatrix3(tmpMatrix)
        this.arrowHelper.setDirection(norm)
        this.arrowHelper.position.copy(point)
        ray = new Ray(this.camera.position,vec(this.camera.position).to(point).normalize())
        info = {name:intersect.object.name,point:point,norm:norm,dist:intersect.distance,mesh:intersect.object,ray:ray}
        return info
    }

    render ()
    {
        var info, _521_18_, _523_21_

        this.lightPlayer.position.copy(this.camera.position)
        this.renderer.render(world.scene,this.camera)
        info = {vecs:Vector.counter,quats:Quaternion.counter,frame:this.renderer.info.render.frame,calls:this.renderer.info.render.calls,lines:this.renderer.info.render.lines,points:this.renderer.info.render.points,textures:this.renderer.info.memory.textures,programs:this.renderer.info.programs.length,geometries:this.renderer.info.memory.geometries,triangles:this.renderer.info.render.triangles}
        this.composer.render()
        this.renderer.info.reset()
        this.fps.draw()
        if (prefs.get('info'))
        {
            this.info = ((_521_18_=this.info) != null ? _521_18_ : new Info)
            return this.info.draw(info)
        }
        else if ((this.info != null))
        {
            this.info.del()
            return delete this.info
        }
    }

    resized (w, h)
    {
        this.renderer.setSize(w,h)
        this.composer.setSize(w,h)
        this.camera.aspect = w / h
        this.camera.size.set(w,h)
        return this.camera.updateProjectionMatrix()
    }
}

module.exports = RTS