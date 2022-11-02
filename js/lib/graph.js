// monsterkodi/kode 0.243.0

var _k_

class Graph
{
    static graph = null

    static balance = []

    static avgs = [[],[],[],[]]

    static avgsNum = 100

    static avgsSecs = 10

    constructor ()
    {
        var x, y

        this.draw = this.draw.bind(this)
        this.width = 4 * Graph.avgsNum * 2
        this.height = 100
        this.size = vec(this.width * window.devicePixelRatio,this.height * window.devicePixelRatio)
        this.canvas = elem('canvas',{class:"graph",width:this.size.x,height:this.size.y})
        y = parseInt(-this.height / 2)
        x = parseInt(-this.width / 2)
        this.canvas.style.transform = `translate3d(${x}px, ${y}px, 0px) scale3d(${1 / window.devicePixelRatio}, -${1 / window.devicePixelRatio}, 1)`
        $("#main").appendChild(this.canvas)
        post.on('tick',this.draw)
    }

    del ()
    {
        post.removeListener('tick',this.draw)
        return this.canvas.remove()
    }

    draw ()
    {
        var ctx

        this.canvas.height = this.canvas.height
        return ctx = this.canvas.getContext('2d')
    }

    static toggle ()
    {
        if (this.graph)
        {
            this.graph.del()
            return this.graph = null
        }
        else
        {
            return this.graph = new Graph
        }
    }
}

module.exports = Graph