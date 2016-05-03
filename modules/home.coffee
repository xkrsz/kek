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

exports.champions = (callback) ->
  Summoner.find {}, (e, summoners) ->
    if e
      log.error e
    if summoners.length
      log.info 'champions: Found summoners in database.'
      champions = {}
      for summoner in summoners
        for champion in summoner.data.championMastery.champions
          if champions[champion.championName]
            champions[champion.championName] += champion.championPoints
          else
            champions[champion.championName] = champion.championPoints

      championsArray = Object.keys(champions).map (key) -> [key, champions[key]]
      championsArray.sort (a, b) -> b[1] - a[1]
      champions = {}
      champions[champion[0]] = champion[1] for champion in championsArray

      topChampionsArray = Object.keys(champions).slice 0, 5
      topChampions = {}
      topChampions[topChampionsArray[i]] = champions[topChampionsArray[i]] for i of topChampionsArray

      callback {
        success: true
        champions: topChampions
      }
    else
      log.info 'champions: No summoners found in database.'
      callback {
        success: true
        total: 0
      }
