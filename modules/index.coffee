bunyan = require 'bunyan'
log = bunyan.createLogger {name: 'kek/modules/summoner'}
request = require 'request'
moment = require 'moment'
summonerModule = require './summoner'

exports.gib = (identity, callback) ->
  summonerModule.updateEverything identity, (r) ->
    if r.success
      request 'https://' + identity.region + '.api.pvp.net/api/lol/' + identity.region +
        '/v1.3/game/by-summoner/' + identity.id + '/recent?api_key=' + process.env.KEY, (e, r, b) ->
          if e
            log.error e
          else
            if r.statusCode == 200
              log.info 'Got games.'
              b = JSON.parse(b)
              games = b.games
              i = 0
              for game in games
                for player in game.fellowPlayers
                  summonerModule.updateEverything {id: player.summonerId, region: identity.region}, (r) ->
                    if r.success
                      log.info ++i + ' summoners added.'
              callback {
                success: true
                summonersAdded: i
              }
