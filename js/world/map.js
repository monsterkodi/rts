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
        this.addTrainStation({pos:[-18,12],dir:Vector.unitX})
        this.addCentralStation({pos:[-18,0],dir:Vector.unitX})
        this.addMiningStation({pos:[0,0],resource:'stuff'})
        this.addMiningStation({pos:[18,0],resource:'blood'})
        return this.addMiningStation({pos:[36,0],resource:'water'})
    }
}

module.exports = Map