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
            state: 'on'
            
        build:
            mine: speed: 0.5
            
        trade:
            mine:  speed: 0.5
            trade: speed: 0.5
            state: 'off'
            sell:
                red:   4
                gelb:  4
                blue:  4
                white: 4
                stone: Stone.red
            buy: 
                stone: Stone.blue
            
        science:
            mine:
                speed:  2.0
                limit:  2
            trade:
                speed:  0.5
                sell:   4
            brain:
                speed:  0.5
                price:  1.0
            base:
                speed:  0.1
                prod:   [1,1,0,0]
            tube:
                speed:  0.5
                gap:    0.2
            build:
                cost:   [0,0,0,8]
            path: 
                length: 2
                
                