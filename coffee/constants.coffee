###
 0000000   0000000   000   000   0000000  000000000   0000000   000   000  000000000   0000000
000       000   000  0000  000  000          000     000   000  0000  000     000     000     
000       000   000  000 0 000  0000000      000     000000000  000 0 000     000     0000000 
000       000   000  000  0000       000     000     000   000  000  0000     000          000
 0000000   0000000   000   000  0000000      000     000   000  000   000     000     0000000 
###

class Enum
    
    constructor: (e) ->
        
        for k,v of e
            @[k] = v

enum = (e) -> new Enum e

module.exports = 
    
    Bend: enum
        flat:       0
        concave:    1
        convex:     2
    
    Face: 
        PX:         0
        PY:         1
        PZ:         2
        NX:         3
        NY:         4
        NZ:         5
                
    Stone:
        gray:       0
        red:        1
        gelb:       2
        blue:       3
        white:      4
        resources:  [1,2,3,4]
        
    Bot:
        base:       1
        mine:       2
        trade:      3
        build:      4
        science:    5
        
    Geom:
        cube:       1
        cone:       2
        sphere:     3
        torus:      4
        icosa:      5
        dodeca:     6
        tetra:      7
        octa:       8
        cylinder:   9
        knot:       10
        dodicos:    11
        octacube:   12
        toruscone:  13
        tubecross:  14

