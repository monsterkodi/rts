###
 0000000   0000000   000      000      0000000    000   000  000000000  000000000   0000000   000   000
000       000   000  000      000      000   000  000   000     000        000     000   000  0000  000
000       000000000  000      000      0000000    000   000     000        000     000   000  000 0 000
000       000   000  000      000      000   000  000   000     000        000     000   000  000  0000
 0000000  000   000  0000000  0000000  0000000     0000000      000        000      0000000   000   000
###

{ log, _ } = require 'kxk'

CanvasButton = require './canvasbutton'

class CallButton extends CanvasButton

    constructor: (div) ->
        
        super div, 'canvasButtonInline'
        
        @render()

    click: -> log 'CallButton.click'

module.exports = CallButton
