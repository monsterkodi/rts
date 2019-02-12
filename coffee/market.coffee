###
00     00   0000000   00000000   000   000  00000000  000000000
000   000  000   000  000   000  000  000   000          000   
000000000  000000000  0000000    0000000    0000000      000   
000 0 000  000   000  000   000  000  000   000          000   
000   000  000   000  000   000  000   000  00000000     000   
###

{ log, _ } = require 'kxk'

{ Bot } = require './constants'

class Market

    constructor: () ->
        
    costForBot: (botType) ->
        
        cost = switch botType
            when Bot.mine    then [500,500,0,0]
            when Bot.trade   then [500,800,200,200]
            when Bot.build   then [500,600,700,800]
            when Bot.science then [800,600,0,0]
        cost

module.exports = Market
