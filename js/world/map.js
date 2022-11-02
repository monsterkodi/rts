// monsterkodi/kode 0.243.0

var _k_

var World

World = require('./world')
class Map extends World
{
    create ()
    {
        return this.stationTest()
    }

    physicsTest ()
    {
        var train, x, y

        for (x = 0; x <= 5; x++)
        {
            for (y = 0; y <= 5; y++)
            {
                train = this.addTrain({traffic:false,boxcars:2})
                train.cars[0].mesh.position.x = x * 4
                train.cars[0].mesh.position.y = y * 30
                train.cars[0].mesh.position.z = 4
                train.cars[1].mesh.position.x = x * 4
                train.cars[1].mesh.position.y = y * 30 + 5
                train.cars[1].mesh.position.z = 4
                train.cars[2].mesh.position.x = x * 4
                train.cars[2].mesh.position.y = y * 30 + 10
                train.cars[2].mesh.position.z = 4
                world.physics.addTrain(train)
            }
        }
    }

    stationTest ()
    {
        this.addCentralStation({pos:[-18,0]})
        this.addCentralStation({pos:[-36,0],dir:Vector.minusY})
        this.addMiningStation({pos:[0,0],resource:'stuff'})
        this.addMiningStation({pos:[18,0],resource:'blood'})
        return this.addMiningStation({pos:[36,0],resource:'water'})
    }

    stationTest2 ()
    {
        var y

        this.addCentralStation([0,0,0])
        for (y = -15; y <= 15; y++)
        {
            if (y !== 0)
            {
                this.addMiningStation([0,y * 6,0],'gold')
            }
            this.addMiningStation([18,y * 6,0],'silver')
            this.addMiningStation([-18,y * 6,0],'gold')
            this.addMiningStation([36,y * 6,0],'steel')
            this.addMiningStation([-36,y * 6,0],'chalk')
            this.addMiningStation([54,y * 6,0],'gold')
            this.addMiningStation([-54,y * 6,0],'silver')
            this.addMiningStation([72,y * 6,0],'gold')
            this.addMiningStation([-72,y * 6,0],'steel')
            this.addMiningStation([90,y * 6,0],'gold')
            this.addMiningStation([-90,y * 6,0],'silver')
        }
    }

    trainTest ()
    {
        var central, n1, n2, n3, t1, t2, t3, t4, t5, t6, train

        n1 = this.addNode([14,0,0],'n1')
        n2 = this.addNode([-26,0,0],'n2')
        n3 = this.addNode([-6,0,0],'n3')
        n2.rotate(180)
        n3.rotate(180)
        t1 = this.connectNodes(n1,n2,'t1')
        t2 = this.connectNodes(n2,n1,'t2')
        t3 = this.connectNodes(n1,n3,'t3')
        t4 = this.connectNodeTracks(n3,n3.outTracks,n2,n2.outTracks,'t4')
        t5 = this.connectNodeTracks(n3,n3.inTracks,n2,n2.inTracks,'t5')
        t6 = this.connectNodes(n3,n1,'t6')
        train = this.addTrain(1,'red')
        train.path.addTrackNode(t1,n2)
        train.path.addTrackNode(t2,n1)
        train.path.addTrackNode(t1,n2)
        train.path.addTrackNode(t2,n1)
        train.path.addTrackNode(t3,n3)
        train.path.addTrackNode(t4,n2)
        train.path.addTrackNode(t5,n3)
        train.path.addTrackNode(t6,n1)
        train = this.addTrain(1,'yellow')
        this.addBoxcar(train,2)
        train.path.addTrackNode(t2,n1)
        train.path.addTrackNode(t1,n2)
        train = this.addTrain(1,'blue')
        this.addBoxcar(train)
        train.path.addTrackNode(t4,n2)
        train.path.addTrackNode(t5,n3)
        train.path.addTrackNode(t6,n1)
        train.path.addTrackNode(t1,n2)
        train.path.addTrackNode(t2,n1)
        train.path.addTrackNode(t3,n3)
        train = this.addTrain(1,'green')
        train.path.addTrackNode(t1,n2)
        train.path.addTrackNode(t2,n1)
        train = this.addTrain(1,'black')
        train.path.addTrackNode(t3,n3)
        train.path.addTrackNode(t4,n2)
        train.path.addTrackNode(t5,n3)
        train.path.addTrackNode(t6,n1)
        train.path.addTrackNode(t1,n2)
        train.path.addTrackNode(t2,n1)
        train = this.addTrain(1,'white')
        train.path.addTrackNode(t2,n1)
        train.path.addTrackNode(t3,n3)
        train.path.addTrackNode(t4,n2)
        train.path.addTrackNode(t5,n3)
        train.path.addTrackNode(t6,n1)
        train.path.addTrackNode(t1,n2)
        return central = this.addCentral([0,0,0])
    }
}

module.exports = Map