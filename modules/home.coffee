bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/modules/home'}

exports.total = (callback) ->
  Summoner.find {}, (e, summoners) ->
    if e
      log.error e
    if summoners.length
      log.info 'total: Found summoners in database.'
      total = 0
      total += summoner.data.championMastery.totalPoints for summoner in summoners
      callback {
        success: true
        total: total
      }
    else
      log.info 'total: No summoners found in database.'
      callback {
        success: true
        total: 0
      }
