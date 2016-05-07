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
              identities = []
              for game in games
                for player in game.fellowPlayers
                  identities.push {
                    id: player.summonerId
                    region: identity.region
                  }
              gibme identities, (r) ->
                callback {
                  success: true
                  message: r.count + ' summoners updated.'
                }

gibme = (identities, count, callback) ->
  summonerModule.updateEverything identities[0], (r) ->
    if r.success
      request 'https://' + identities[0].region + '.api.pvp.net/api/lol/' + identities[0].region +
        '/v1.3/game/by-summoner/' + identities[0].id + '/recent?api_key=' + process.env.KEY, (e, r, b) ->
          if e
            log.error e
          else
            if r.statusCode == 200
              b = JSON.parse(b)
              games = b.games
              newIdentities = []
              for game in games
                for player in game.fellowPlayers
                  newIdentities.push {
                    id: player.summonerId
                    region: identities[0].region
                  }
              updateIdentity newIdentities, count, (r) ->
                identities.shift()
                if identities.length > 0
                  gibme identities, r.count, callback
                else
                  callback {
                    success: true
                    message: 'kthx.'
                    count: count
                  }
            else
              identities.shift()
              if identities.length > 0
                gibme identities, callback
              else
                callback {
                  success: true
                  message: 'kthx.'
                }

updateIdentity = (identities, count, callback) ->
  summonerModule.updateEverything identities[0], (r) ->
    identities.shift()
    if identities.length > 0
      updateIdentity identities, ++count, callback
    else
      callback {
        success: true
        count: count
      }
