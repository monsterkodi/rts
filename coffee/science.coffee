###
 0000000   0000000  000  00000000  000   000   0000000  00000000
000       000       000  000       0000  000  000       000     
0000000   000       000  0000000   000 0 000  000       0000000 
     000  000       000  000       000  0000  000       000     
0000000    0000000  000  00000000  000   000   0000000  00000000
###

{ log, _ } = require 'kxk'

class Science

    @tree = 
        base:
            speed:  x:0, y:0, v:[0.1]
            prod:   x:0, y:1, v:[[1,1,0,0]]
        brain:
            speed:  x:1, y:0, v:[0.5,0.75,1.0,1.5,2.0,3.0]
            price:  x:1, y:1, v:[1,0.9,0.8,0.7,0.6,0.5]
        trade:
            speed:  x:2, y:0, v:[0.5,0.75,1.0,1.5,2.0,3.0]
            sell:   x:2, y:1, v:[4,3,2,1]
        mine:
            speed:  x:0, y:2, v:[2.0,2.5,3.0,3.5,4.0,5.0]
            limit:  x:1, y:2, v:[2,3,4,5,6,7,8]
        build:
            cost:   x:2, y:2, v:[[8,16,24,32]]
        tube:
            speed:  x:0, y:3, v:[0.5]
            gap:    x:2, y:3, v:[0.2]
        path: 
            length: x:1, y:3, v:[2]

    @stars: (scienceKey) ->
            
    @queue: (scienceKey) ->
        
        log "Science.queue #{scienceKey}"
            
module.exports = Science
