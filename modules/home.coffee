bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/modules/home'}
rankingModule = require './ranking'

exports.total = (callback) ->
  Summoner.find {}, (e, summoners) ->
    if e
      log.error e
    if summoners.length
      log.info 'total: Found summoners in database.'
      total = 0
      total += summoner.data.championMastery.totalPoints if summoner.data.championMastery.totalPoints for summoner in summoners
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
  rankingModule.apiRankingChampions (r) ->
    callback r

exports.roles = (callback) ->
  Summoner.find {}, (e, summoners) ->
    if e
      log.error e
    if summoners.length
      roles = {}
      for summoner in summoners
        summoner = summoner.toObject()
        cachedRoles = summoner.data.championMastery.rolesPoints
        cachedRolesArray = Object.keys(summoner.data.championMastery.rolesPoints)
        for i of cachedRolesArray
          if roles[cachedRolesArray[i]]
            roles[cachedRolesArray[i]] += cachedRoles[cachedRolesArray[i]]
          else
            roles[cachedRolesArray[i]] = cachedRoles[cachedRolesArray[i]]

      rolesArray = Object.keys(roles).map (key) -> [key, roles[key]]
      rolesArray.sort (a, b) -> b[1] - a[1]
      roles = {}
      roles[role[0]] = role[1] for role in rolesArray

      callback {
        success: true
        roles: roles
      }
