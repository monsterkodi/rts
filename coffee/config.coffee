###
 0000000   0000000   000   000  00000000  000   0000000 
000       000   000  0000  000  000       000  000      
000       000   000  000 0 000  000000    000  000  0000
000       000   000  000  0000  000       000  000   000
 0000000   0000000   000   000  000       000   0000000 
###

{ Stone } = require './constants'

module.exports = 
    
    default:
            
        world:
            speed: [1/8, 1/4, 1/2, 1, 2, 4, 8, 16, 32, 64, 128, 256, 512]
        
        ai: delay: 20
        
        storage:
            # stones:[ 8 *8, 8 *8, 8 *8, 8 *8]
            stones:[ 56, 64, 72, 64 ]
            # stones:[ 200,160,80,8 ]
            # stones:[80,77,13,79]
            # stones:[ 5,6,7,8 ]
            
        cancer: 
            growTime: 40
            ageTime:  20
        
        cost: 
            brain: [ 4 *8, 2 *8, 0   , 0   ]
            trade: [ 3 *8, 4 *8, 3 *8, 2 *8]
            build: [ 2 *8, 3 *8, 4 *8, 5 *8]
            mine:  [ 2 *8, 2 *8, 2 *8, 2 *8]
            
        scienceCost:  [0,1,2,3,4,5]
        scienceSteps: [0,8,16,32,64,128]
            
        nonMineSpeed: 0.2
           
        spark: speed:  0.5
        
        monster: 
            speed:    0.2
            # speed:    0.02
            health:   32
            resource: 256
            
            
            