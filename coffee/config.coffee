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
            stones: [500, 500, 0, 0]
            capacity: 1000
            
        cost: 
            mine:  [400,200,0,0]
            trade: [300,600,0,0]
            brain: [500,100,500,0]
            build: [500,500,0,500]
              
        base:
            prod: speed: 1
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
