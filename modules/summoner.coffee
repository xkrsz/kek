bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/modules/summoner'}
request 				= require 'request'
moment 					= require 'moment'

exports.toPlatform = (region) ->
	return {
		eune	: 'EUN1'
		euw		: 'EUW1'
		br 		: 'BR1'
		jp 		: 'JP1'
		kr 		: 'KR'
		lan 	: 'LA1'
		las 	: 'LA2'
		na 		: 'NA1'
		oce 	: 'OC1'
		ru 		: 'RU'
		tr 		: 'TR1'
	}[region]

exports.findChampion = (id, callback) ->
	Champion.findOne {id: id}, (e, champion) ->
		if e
			log.error e
			callback {success: false, message: e}
		if champion
			callback {success: true, champion: champion}
		else
			callback {success: false, message: 'Champion not found.'}

exports.updateSummoner = (identity, callback) -> # identity = {key || id, region}
	log.info 'Updating summoner identity...'
	if identity.region
		if identity.key
			identity.key = identity.key.toLowerCase().replace ' ', ''
			link = 'https://' + identity.region + '.api.pvp.net/api/lol/' + identity.region + '/v1.4/summoner/by-name/' +
				identity.key + '?api_key=' + process.env.KEY
		else if identity.id
			link = 'https://' + identity.region + '.api.pvp.net/api/lol/' + identity.region + '/v1.4/summoner/' +
				identity.id + '?api_key=' + process.env.KEY
	request link, (e, r, b) ->
		if e
			log.error e
			callback {
				success		: false
				message		: e
			}
		else if r.statusCode == 200
			b = JSON.parse(b)[identity.key || identity.id]
			identity = {
				key 			: identity.key || b.name.toLowerCase().replace ' ', ''
				name 			: b.name
				id 				: b.id
				profileIconId	: b.profileIconId
				summonerLevel 	: b.summonerLevel
				region 			: identity.region
				platform 		: exports.toPlatform identity.region
			}
			Summoner.findOne {
				"identity.id"		: identity.id
				"identity.region"	: identity.region
			}, (e, cachedSummoner) ->
				if e
					log.error e
				else
					if cachedSummoner
						log.info 'Found summoner in database.'
						cachedSummoner.identity.key = identity.key
						cachedSummoner.identity.name = identity.name
						cachedSummoner.identity.profileIconId = identity.profileIconId
						cachedSummoner.identity.summonerLevel = identity.summonerLevel
						now = moment()
						cachedSummoner.identity.updatedAt = now
						cachedSummoner.updatedAt = now
						cachedSummoner.save (e, cachedSummoner) ->
							if e
								if e.code == 11000
									log.error 'Summoner already exists in database. ' + e
									callback {
										success: false
										message: e
									}
								else
									log.error e
							if cachedSummoner
								callback {
								    success     : true
								    summoner    : cachedSummoner
								}
					else
						log.info 'Summoner not found in database.'
						now = moment() # that's to ensure createdAt and updatedAt are the same
						identity.createdAt = now
						identity.updatedAt = now
						summoner = {
							identity 	: identity
							createdAt 	: now
							updatedAt 	: now
						}
						newSummoner = new Summoner summoner
						newSummoner.save (e, newSummoner) ->
							if e
								if e.code == 11000
									log.error 'Summoner already exists in database.'
								else
									log.error e
							else
								log.info 'New summoner saved.'
								exports.updateEverything identity, (r) ->
									callback {
										success: true
										summoner: newSummoner
									}
		else if r.statusCode == 429
			Summoner.findOne {
				"identity.id" : identity.id
				"identity.region" : identity.region
			}, (e, cachedSummoner) ->
				if e
					log.error e
				if cachedSummoner
					log.info 'Found summoner in database.'
					callback {
						success 		: true
						summoner 		: cachedSummoner
						message 		: 'Rate limit exceeded.'
					}
				else
					callback {
						success: false
						message: 'Rate limit exceeded.'
						statusCode: r.statusCode
					}
		else
			Summoner.findOne {
				"identity.id" : identity.id
				"identity.region" : identity.region
			}, (e, cachedSummoner) ->
				if e
					log.error e
				if cachedSummoner
					log.info 'Found summoner in database.'
					callback {
						success 		: true
						summoner 		: cachedSummoner
						message 		: 'An error occured while updating from API.'
						statusCode 		: r.statusCode
					}
				else
					callback {
						success: false
						message: 'An error occured. Please try again later.'
						statusCode: r.statusCode
					}

exports.updateChampionMastery = (identity, callback) ->
	log.info 'Updating champion mastery...'
	if !identity.id || !identity.region
		log.info 'Data missing, can\'t update champion mastery.'
		callback {
			success: false
			message: 'y u no gib data m9'
		}
	Summoner.findOne {
			"identity.id" 		: identity.id
			"identity.region" 	: identity.region
	}, (e, cachedSummoner) ->
		if e
			log.error e
		if cachedSummoner
			log.info 'Found summoner in database.'
			if checkDiff(cachedSummoner.data.championMastery.updatedAt)
				log.info 'Summoner eligible for update.'
				request 'https://' + cachedSummoner.identity.region + '.api.pvp.net/championmastery/location/' + cachedSummoner.identity.platform + '/player/' + cachedSummoner.identity.id + '/champions?api_key=' + process.env.KEY, (e, r, b) ->
					if e
						log.error e
					else if r.statusCode == 200
						b = JSON.parse(b)
						log.info 'Got mastery data'
						Champion.find {}, (e, champions) ->
							if e
								log.error e
							if champions.length > 0
								for mastery in b
									for champion in champions
										if champion.id == mastery.championId
											mastery.championName = champion.name
								championMastery = {champions: b}
								exports.roleScores championMastery, (r) ->
									if r.success
										for prop of r.championMastery
											championMastery[prop] = r.championMastery[prop]
										now = moment()
										championMastery.updatedAt = now
										cachedSummoner.data.championMastery = championMastery
										cachedSummoner.updatedAt = now
										cachedSummoner.save (e, cachedSummoner) ->
											if e
												log.error e
												callback {success: false, message: e}
											else if cachedSummoner
												log.info 'Champion masteries saved.'
												callback {
													success: true
													championMastery: cachedSummoner.data.championMastery
												}
											else
												log.error 'Couldn\'t save champion masteries.'
												callback {success: false, message: 'Couldn\'t save champion masteries.'}
			else
				log.info 'Not updating, too soon.'
				callback {
					success: true
					championMastery: cachedSummoner.data.championMastery
				}
		else
			log.info 'Summoner not found in database.'
			exports.updateEverything {id: identity.id, region: identity.region}, (r) ->
				if r.success
					exports.updateChampionMastery {id: identity.id, region: identity.region}, callback

exports.updateStatsRanked = (identity, callback) -> # identity = {id, region}
	if !identity.id || !identity.region
		log.error 'Missing data in updateStatsRanked request.'
		callback {
			success: false
			message: 'dood 1 need mor d8a.'
		}

	Summoner.findOne {
		"identity.id": identity.id
		"identity.region": identity.region
	}, 'data.statsRanked', (e, cachedSummoner) ->
		if e
			log.error e
		if cachedSummoner
			log.info 'Summoner found in database'
			if checkDiff(cachedSummoner.data.statsRanked.updatedAt)
				request 'https://' + identity.region + '.api.pvp.net/api/lol/' + identity.region + '/v1.3/stats/by-summoner/' + identity.id + '/ranked?season=SEASON2016&api_key=' + process.env.KEY, (e, r, b) ->
					if e
						log.error e
					else
						if r.statusCode == 200
							log.info 'Got statsRanked'
							b = JSON.parse(b).champions
							cachedSummoner.data.statsRanked.champions = b
							cachedSummoner.data.statsRanked.updatedAt = moment()
							cachedSummoner.save (e, cachedSummoner) ->
								if e
									log.error e
								if cachedSummoner
									log.info 'statsRanked saved.'
									callback {
										success: true
										statsRanked: cachedSummoner.data.statsRanked
									}
								else
									log.error 'statsRanked not saved, something\'s wrong.'
									callback {
										success: false
										message: 'statsRanked couldn\'t be saved.'
									}
						else if r.statusCode == 429
							log.error 'updateStatsRanked: rate limit exceeded.'
							callback {
								success: true
								statsRanked: cachedSummoner.data.statsRanked
							}
						else
							log.error 'updateStatsRanked: problem with API: ' + r.statusCode
							callback {
								success: true
								statsRanked: cachedSummoner.data.statsRanked
							}
			else
				log.info 'Not updating statsRanked, too soon.'
				callback {
					success: true
					statsRanked: cachedSummoner.data.statsRanked
				}
		else
			log.info 'Summoner not found in database.'
			exports.updateEverything identity, (r) ->
				if r.success
					exports.updateStatsRanked identity, callback

exports.updateLeague = (identity, callback) -> # identity = {id, region}
	if !identity.id || !identity.region
		log.info 'updateLeague: Missing data.'
		callback {
			success: false
			message: 'i need know wat u want 2 upd8 m8.'
		}
	Summoner.findOne {
		"identity.id": identity.id
		"identity.region": identity.region
	}, 'data.league', (e, cachedSummoner) ->
		if e
			log.error e
		if cachedSummoner
			log.info 'updateLeague: Summoner found in database.'
			if checkDiff(cachedSummoner.data.league.updatedAt)
				request 'https://' + identity.region + '.api.pvp.net/api/lol/' + identity.region + '/v2.5/league/by-summoner/' + identity.id + '/entry?api_key=' + process.env.KEY, (e, r, b) ->
					if e
						log.error e
					else
						if r.statusCode == 200
							log.info 'updateLeague: Got league.'
							b = JSON.parse(b)[identity.id][0]
							league = {
								name: b.name
								tier: b.tier
								division: b.entries[0].division
								leaguePoints: b.entries[0].leaguePoints
								wins: b.entries[0].wins
								losses: b.entries[0].losses
								updatedAt: moment()
							}
							cachedSummoner.data.league = league
							cachedSummoner.save (e, cachedSummoner) ->
								if e
									log.error e
								if cachedSummoner
									log.info 'updateLeague: Summoner updated.'
									callback {
										success: true
										league: cachedSummoner.data.league
									}
						else if r.statusCode == 429
							log.info 'updateLeague: Rate limit exceeded.'
							callback {
								success: true
								league: cachedSummoner.data.league
							}
						else
							log.info 'updateLeague: An error occurred: ' + r.statusCode
							callback {
								success: true
								league: cachedSummoner.data.league
							}
			else
				log.info 'updateLeague: Not updating, too soon.'
				callback {
					success: true
					league: cachedSummoner.data.league
				}
		else
			log.info 'updateLeague: Summoner not found in database, calling updateEverything.'
			exports.updateEverything identity, (r) ->
				if r.success
					exports.updateLeague identity, callback

exports.updateEverything = (identity, callback) -> # identity = {id, region}
	exports.updateSummoner identity, (r) ->
		if r.success
			exports.updateChampionMastery identity, (r) ->
				if r.success
					exports.updateStatsRanked identity, (r) ->
					if r.success
						exports.updateLeague identity, (r) ->
							if r.success
								log.info 'Complete update finished with no errors.'
								callback {
									success: true
								}

exports.roleScores = (championMastery, callback) ->
	Champion.find {}, (e, champions) ->
		if e
			log.error e
			callback {success: false, message: e}
		else if champions
			roles = {
				"Assassin" 	: 0
				"Fighter" 	: 0
				"Mage" 			: 0
				"Support" 	: 0
				"Tank"			: 0
				"Marksman" 	: 0
			}
			totalPoints = 0
			for mastery in championMastery.champions			# loop through all saved champion masteries
				for champion in champions 									# loop through all champions to find matching one
					if champion.id == mastery.championId			# found champion
						for tag in champion.tags								# loop through champion tags and assign score
							roles[tag] += mastery.championPoints
				totalPoints += mastery.championPoints

			rolesArray = Object.keys(roles).map (key) -> [key, roles[key]]
			rolesArray.sort (a, b) -> b[1] - a[1]
			roles = {}
			roles[role[0]] = role[1] for role in rolesArray

			callback {
				success: true
				championMastery	: {
					totalPoints		: totalPoints
					rolesPoints		: roles
				}
			}
		else
			callback {success: false, message: 'No champions found in database.'}

exports.apiSummonerOverview = (identity, callback) -> # identity = {id, region}
	exports.updateChampionMastery identity, (r) ->
		if r.success
			# roles
			rolesPoints = r.championMastery.rolesPoints.toObject()
			# top 3 champions
			topChampions = r.championMastery.champions.slice 0, 3

			callback {
				success: true
				roles: rolesPoints
				totalPoints: r.championMastery.totalPoints
				topChampions: topChampions
			}

exports.apiSummonerChampions = (identity, callback) ->
	if !identity.id || !identity.region
		log.error 'Data missing in apiSummonerChampions request.'
		callback {
			success: false
			message: 'U no gib enough data dude come on.'
		}
	exports.updateChampionMastery identity, (r) ->
		if r.success
			champions = r.championMastery.champions.toObject()
			exports.updateStatsRanked identity, (r) ->
				if r.success
					statsRanked = r.statsRanked.champions.toObject()
					for champion in champions
						delete champion._id
						for stat in statsRanked
							if stat.id == champion.championId
								games = stat.stats.totalSessionsPlayed
								k = Number((stat.stats.totalChampionKills / games).toFixed(2))
								d = Number((stat.stats.totalDeathsPerSession / games).toFixed(2))
								a = Number((stat.stats.totalAssists / games).toFixed(2))
								kda = Number(((k + a) / d).toFixed(2))
								g = Number((stat.stats.totalGoldEarned / games).toFixed(0))
								m = Number((stat.stats.totalMinionKills / games).toFixed(0))
								w = stat.stats.totalSessionsWon
								l = stat.stats.totalSessionsLost
								wr = Number((w / games).toFixed(2))
								champion.games = games
								champion.kills = k
								champion.deaths = d
								champion.assists = a
								champion.kda = kda
								champion.gold = g
								champion.minions = m
								champion.winrate = wr
					callback {
						success: true
						champions: champions
					}
				else
					log.error 'Something\'s wrong with apiSummonerChampions: ' + r.message

exports.apiSummonerLeague = (identity, callback) -> # identity = {id, region}
	if !identity.id || !identity.region
		log.info 'apiSummonerLeague: missing data in api call.'
		callback {
			success: false
			message: 'u sur haz mor d8a gib me it adn i will w0rk.'
		}
	exports.updateLeague identity, (r) ->
		if r.success
			league = r.league.toObject()
			wr = Number((league.wins / (league.wins + league.losses)).toFixed(2))
			league.winrate = wr
			callback {
				success: true
				league: league
			}
		else
			log.error 'apiSummonerLeague: updateLeague didn\'t succeed.'
			callback {
				success: false
				message: 'An error occurred while updating summoner league.'
			}

checkDiff = (date) ->
	timeDiff = moment().diff(moment(date), 'minutes') || 0
	if timeDiff > 30 || !date
		true
	else
		false
