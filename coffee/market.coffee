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
            when Bot.mine  then [400,200,0,0]
            when Bot.trade then [300,600,0,0]
            when Bot.brain then [500,100,1000,0]
            when Bot.build then [500,500,0,1000]
        cost

module.exports = Market
