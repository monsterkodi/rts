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
            when Bot.mine    then [10,20,30,40]
            when Bot.trade   then [50,60,70,80]
            when Bot.build   then [90,100,111,122]
            when Bot.science then [1000,1000,1000,1000]
        cost

module.exports = Market
