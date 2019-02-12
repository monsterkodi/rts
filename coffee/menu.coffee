###
00     00  00000000  000   000  000   000
000   000  000       0000  000  000   000
000000000  0000000   000 0 000  000   000
000 0 000  000       000  0000  000   000
000   000  00000000  000   000   0000000 
###

{ log, _ } = require 'kxk'

{ Bot } = require './constants'

Button = require './button'

class Menu

    constructor: ->

        y = 100
        for bot in Bot.values
            new Button bot, 0, y
            y += 100

module.exports = Menu
