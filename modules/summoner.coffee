bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/modules/summoner'}
request 				= require 'request'
moment 					= require 'moment'

exports.find = (identity, callback) -> # identity = {key, region}
	log.info 'Finding summoner...'
	identity.key = identity.key.toLowerCase().replace ' ', ''
	identity.region = identity.region.toLowerCase().replace ' ', ''

	request 'https://' + identity.region + '.api.pvp.net/api/lol/' + identity.region + '/v1.4/summoner/by-name/' + identity.key + '?api_key=' + process.env.KEY, (e, r, b) ->
		if e
			log.error e
			callback {
				success		: false
				message		: e
			}
		else if r.statusCode == 200
			b = JSON.parse(b)[identity.key]
			log.info 'Got summoner.'
			identity = {
				key 			: identity.key
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
									log.error 'Summoner already exists in database.'
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
								callback {
								    success     : true
								    summoner    : newSummoner
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
exports.getChampionMasteries = (identity, callback) -> # identity = {id, region}
	log.info 'Processing champion masteries request...'
	Summoner.findOne {
			"identity.id" 		: identity.id
			"identity.region" 	: identity.region
	}, (e, cachedSummoner) ->
		if e
			log.error e
		if cachedSummoner
			log.info 'Found summoner in database.'
			timeDiff = moment().diff(moment(cachedSummoner.data.championMastery.updatedAt), 'minutes') || 0
			if timeDiff > 30 || !cachedSummoner.data.championMastery.updatedAt
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
										championMastery.createdAt = now
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
			exports.platinumCardCompletePremiumBundle {id: identity.id, region: identity.region}, (r) ->
				callback r
exports.toPlatform = (region) ->
	platforms = {
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
	}
	return platforms[region]

exports.findChampion = (id, callback) ->
	Champion.findOne {id: id}, (e, champion) ->
		if e
			log.error e
			callback {success: false, message: e}
		if champion
			callback {success: true, champion: champion}
		else
			callback {success: false, message: 'Champion not found.'}

exports.roleScores = (championMastery, callback) ->
	Champion.find {}, (e, champions) ->
		if e
			log.error e
			callback {success: false, message: e}
		else if champions
			roles = {
				"Assassin" 	: 0
				"Fighter" 	: 0
				"Mage" 		: 0
				"Support" 	: 0
				"Tank"		: 0
				"Marksman" 	: 0
			}
			totalPoints = 0
			for mastery in championMastery.champions				# loop through all saved champion masteries
				for champion in champions 							# loop through all champions to find matching one
					if champion.id == mastery.championId			# found champion
						for tag in champion.tags					# loop through champion tags and assign score
							roles[tag] += mastery.championPoints
				totalPoints += mastery.championPoints
			callback {
				success: true
				championMastery	: {
					totalPoints		: totalPoints
					rolesPoints		: roles
				}
			}
		else
			callback {success: false, message: 'No champions found in database.'}

exports.platinumCardCompletePremiumBundle = (identity, callback) -> # identity = {id, region}

exports.apiSummonerOverview = (identity, callback) -> # identity = {id, region}
	exports.getChampionMasteries identity, (r) ->
		if r.success
			# roles
			rolesPoints = r.championMastery.rolesPoints.toObject()
			rolesArray = Object.keys(rolesPoints).map (key) -> [key, rolesPoints[key]]
			rolesArray.sort (a, b) -> b[1] - a[1]
			rolesPoints = {}
			rolesPoints[role[0]] = role[1] for role in rolesArray # that's why I like CoffeeScript

			# top 3 champions
			topChampions = r.championMastery.champions.slice 0, 3

			callback {
				success: true
				roles: rolesPoints
				topChampions: topChampions
			}