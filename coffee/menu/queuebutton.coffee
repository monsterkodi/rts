###
 0000000   000   000  00000000  000   000  00000000  0000000    000   000  000000000  000000000   0000000   000   000
000   000  000   000  000       000   000  000       000   000  000   000     000        000     000   000  0000  000
000 00 00  000   000  0000000   000   000  0000000   0000000    000   000     000        000     000   000  000 0 000
000 0000   000   000  000       000   000  000       000   000  000   000     000        000     000   000  000  0000
 00000 00   0000000   00000000   0000000   00000000  0000000     0000000      000        000      0000000   000   000
###

BrainButton = require './brainbutton'

class QueueButton extends BrainButton

    constructor: (@menu, @info) ->

        super @menu, @info.scienceKey
        
        @canvas.classList.add 'queueButton'

    transMat: (mat) -> mat
        
    stars: -> @info.stars
  
    click: => Science.dequeue @info
    
module.exports = QueueButton
