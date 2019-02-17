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
            
        storage:
            capacity: 80
            stones:[ 8 *8, 8 *8, 8 *8, 8 *8]
            
        cost: 
            brain: [ 4 *8, 2 *8, 0   , 0   ]
            trade: [ 3 *8, 4 *8, 3 *8, 2 *8]
            build: [ 2 *8, 3 *8, 4 *8, 5 *8]
            mine:  [ 2 *8, 2 *8, 2 *8, 2 *8]
            
        scienceCost:  [0,1,2,3,4,5]
        scienceSteps: [0,8,16,32,64,128]
            
        nonMineSpeed: 0.2
            
        brain: state: 'on'
        build: state: 'build'
            
        trade:
            state: 'on'
            sell:  Stone.red
            buy:   Stone.blue
            