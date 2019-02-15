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
            stones:[ 5 *8, 5 *8, 5 *8, 5 *8]
            
        cost: 
            brain: [ 4 *8, 2 *8, 0   , 0   ]
            trade: [ 3 *8, 4 *8, 3 *8, 2 *8]
            build: [ 2 *8, 3 *8, 4 *8, 5 *8]
            mine:  [ 2 *8, 2 *8, 2 *8, 2 *8]
              
        base:
            prod: speed: 0.1
            mine: speed: 0.5
            
        mine:
            mine: speed: 2
            
        brain:
            mine: speed: 0.5
            
        build:
            mine: speed: 0.5
            
        trade:
            mine:  speed: 0.5
            trade: speed: 0.5
            state: 'off'
            sell:
                red:   4
                gelb:  4
                blue:  3
                white: 3
                stone: Stone.red
            buy: 
                stone: Stone.blue
            
        science:
            path: 
                length: 2
                speed:  0.5
                gap:    0.2
