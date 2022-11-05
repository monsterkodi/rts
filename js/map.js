// monsterkodi/kode 0.243.0

var _k_

var World

World = require('./world')
class Map extends World
{
    create ()
    {
        return this.trainTest()
    }

    trainTest ()
    {
        var n1, n2, n3, t1, t2, t3, t4, t5, t6, train

        n1 = this.addNode([20,0,0],'n1')
        n2 = this.addNode([-20,0,0],'n2')
        n3 = this.addNode([0,0,0],'n3')
        n2.rotate(180)
        n3.rotate(180)
        t1 = this.connectNodes(n1,n2,'t1')
        t2 = this.connectNodes(n2,n1,'t2')
        t3 = this.connectNodes(n1,n3,'t3')
        t4 = this.connectNodeTracks(n3,n3.outTracks,n2,n2.outTracks,'t4')
        t5 = this.connectNodeTracks(n3,n3.inTracks,n2,n2.inTracks,'t5')
        t6 = this.connectNodes(n3,n1,'t6')
        train = this.addTrain(1,'red')
        this.addBoxcar(train,3)
        train.setColor(Color.train.red)
        train.path.addTrackNode(t1,n2)
        train.path.addTrackNode(t2,n1)
        train.path.addTrackNode(t1,n2)
        train.path.addTrackNode(t2,n1)
        train.path.addTrackNode(t3,n3)
        train.path.addTrackNode(t4,n2)
        train.path.addTrackNode(t5,n3)
        train.path.addTrackNode(t6,n1)
        train = this.addTrain(1,'yellow')
        this.addBoxcar(train,4)
        train.setColor(Color.train.yellow)
        train.path.addTrackNode(t2,n1)
        train.path.addTrackNode(t1,n2)
        train = this.addTrain(1,'blue')
        this.addBoxcar(train,2)
        train.setColor(Color.train.blue)
        train.path.addTrackNode(t4,n2)
        train.path.addTrackNode(t5,n3)
        train.path.addTrackNode(t6,n1)
        train.path.addTrackNode(t1,n2)
        train.path.addTrackNode(t2,n1)
        return train.path.addTrackNode(t3,n3)
    }
}

module.exports = Map