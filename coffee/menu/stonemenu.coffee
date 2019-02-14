###
 0000000  000000000   0000000   000   000  00000000  00     00  00000000  000   000  000   000
000          000     000   000  0000  000  000       000   000  000       0000  000  000   000
0000000      000     000   000  000 0 000  0000000   000000000  0000000   000 0 000  000   000
     000     000     000   000  000  0000  000       000 0 000  000       000  0000  000   000
0000000      000      0000000   000   000  00000000  000   000  00000000  000   000   0000000 
###

{ log, _ } = require 'kxk'

{ Stone }   = require '../constants'
StoneButton = require './stonebutton'
SubMenu     = require './submenu'

class StoneMenu extends SubMenu

    constructor: (button) ->

        super button

        for stone in Stone.resources
            @addButton Stone.toString(stone), new StoneButton @div, stone

module.exports = StoneMenu
