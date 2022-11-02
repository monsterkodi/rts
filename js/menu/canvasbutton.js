// monsterkodi/kode 0.243.0

var _k_

class CanvasButton
{
    constructor (div, clss = 'canvasButton', lightPos, camPos)
    {
        var _35_18_, _36_18_, _37_18_, _38_18_, _39_18_

        this.lightPos = lightPos
        this.camPos = camPos
    
        this.render = this.render.bind(this)
        this.update = this.update.bind(this)
        this.unhighlight = this.unhighlight.bind(this)
        this.highlight = this.highlight.bind(this)
        this.del = this.del.bind(this)
        this.highlighted = false
        this.width = 100
        this.height = 100
        this.size = vec(this.width * window.devicePixelRatio,this.height * window.devicePixelRatio)
        this.name = 'CanvasButton'
        this.meshes = {}
        if (!CanvasButton.renderer)
        {
            CanvasButton.renderer = new THREE.WebGLRenderer({antialias:true,alpha:true})
            CanvasButton.renderer.setPixelRatio(window.devicePixelRatio)
            CanvasButton.renderer.setSize(this.width,this.height)
            CanvasButton.renderer.setClearColor(0,0)
        }
        this.canvas = elem('canvas',{class:clss,width:this.size.x,height:this.size.y})
        div.appendChild(this.canvas)
        this.canvas.button = this
        this.scene = new THREE.Scene()
        this.highFov = ((_35_18_=this.highFov) != null ? _35_18_ : 33)
        this.normFov = ((_36_18_=this.normFov) != null ? _36_18_ : 40)
        this.lightPos = ((_37_18_=this.lightPos) != null ? _37_18_ : vec(0,10,6))
        this.lookPos = ((_38_18_=this.lookPos) != null ? _38_18_ : vec(0,0,0))
        this.camPos = ((_39_18_=this.camPos) != null ? _39_18_ : vec(0.3,0.6,1).normal().mul(12))
        this.initCamera()
        this.camera.position.copy(this.camPos)
        this.camera.lookAt(this.lookPos)
        this.camera.updateProjectionMatrix()
        this.initLight()
        this.initScene()
        this.dirty = true
    }

    del ()
    {
        return this.canvas.remove()
    }

    initLight ()
    {
        this.light = new THREE.DirectionalLight(0xffffff)
        this.light.position.copy(this.lightPos)
        this.scene.add(this.light)
        return this.scene.add(new THREE.AmbientLight(0xffffff))
    }

    initCamera ()
    {
        return this.camera = new THREE.PerspectiveCamera(this.normFov,this.width / this.height,0.01,100)
    }

    initScene ()
    {}

    highlight ()
    {
        return this.highlighted = true
    }

    unhighlight ()
    {
        return this.highlighted = false
    }

    update ()
    {
        return this.dirty = true
    }

    animate (delta)
    {
        if (this.dirty)
        {
            return this.render()
        }
    }

    render ()
    {
        var context

        if (this.dirty)
        {
            this.dirty = false
            CanvasButton.renderer.clear()
            CanvasButton.renderer.render(this.scene,this.camera)
            context = this.canvas.getContext('2d')
            context.clearRect(0,0,2 * this.width,2 * this.height)
            return context.drawImage(CanvasButton.renderer.domElement,0,0)
        }
    }
}

module.exports = CanvasButton