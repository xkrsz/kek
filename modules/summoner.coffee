bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/modules/summoner'}
request 				= require 'request'

exports.find = (summoner, callback) -> # summoner = {key, region}
	log.info 'Finding summoner...'
	summoner.key = summoner.key.toLowerCase().replace ' ', ''
	summoner.region = summoner.region.toLowerCase().replace ' ', ''

	request 'https://' + summoner.region + '.api.pvp.net/api/lol/' + summoner.region + '/v1.4/summoner/by-name/' + summoner.key + '?api_key=' + process.env.KEY, (e, r, b) ->
		if e
			log.error e
			callback {
				success		: false
				message		: e
			}
		else if r.statusCode == 200
			b = JSON.parse(b)[summoner.key]
			log.info {summoner: b}, 'Got summoner.'
			summoner = {
				key 			: summoner.key
				name 			: b.name
				id 				: b.id
				profileIconId	: b.profileIconId
				summonerLevel 	: b.summonerLevel
				region 			: summoner.region
				platform 		: exports.toPlatform summoner.region
			}

			Summoner.findOne {
				id 		: summoner.id
				region 	: summoner.region
			}, (e, cachedSummoner) ->
				if e
					log.error e
				else
					if cachedSummoner
						log.info 'Found summoner in database.'
					else
						log.info 'Summoner not found in database.'
						newSummoner = new Summoner summoner
						newSummoner.save (e, newSummoner) ->
							if e
								if e.code == 11000
									log.error 'Summoner already exists in database.'
								else
									log.error e
							else
								log.info 'New summoner saved.'
					exports.getChampionMasteries {
						id 			: summoner.id
						region		: summoner.region
						platform	: summoner.platform
					}, (r) ->


			callback {
				success 		: true
				summoner 		: summoner
				}
		else if r.statusCode == 429
			callback {
				success 		: false
				message 		: 'Rate limit exceeded.'
			}
		else
			log.error 'An error occured.'
			callback {
				success 		: false
				message 		: 'An error occured. Please try again later.'
				statusCode 		: r.statusCode
			}
exports.getChampionMasteries = (summoner, callback) -> # summoner = {id, region, platform}
	log.info 'Updating summoner...'
	request 'https://' + summoner.region + '.api.pvp.net/championmastery/location/' + summoner.platform + '/player/' + summoner.id + '/champions?api_key=' + process.env.KEY, (e, r, b) ->
		if e
			log.error e
		else if r.statusCode == 200
			b = JSON.parse(b)
			log.info 'Got mastery data'
			Summoner.findOne {
				id 		: summoner.id
				region 	: summoner.region
			}, (e, cachedSummoner) ->
				if e
					log.error e
				else
					if cachedSummoner
						cachedSummoner.championMasteries = b
						cachedSummoner.save (e, cachedSummoner) ->
							if e
								log.error e
							else if cachedSummoner
								log.info 'Champion masteries saved.'
								exports.roleScores cachedSummoner, (r) ->
									if r.success
										log.info r.roles
									else
										log.error r.message
							else
								log.error 'Couldn\'t save champion masteries.'
					else
						log.error 'Tried to update summoner, but he doesn\'t exists in database.'

exports.toPlatform = (region) ->
	switch region
		when 'eune' 	then return 'EUN1'
		when 'euw' 		then return 'EUW1'
		when 'br'		then return 'BR1'
		when 'jp'		then return 'JP1'
		when 'kr' 		then return 'KR'
		when 'lan' 		then return 'LA1'
		when 'las' 		then return 'LA2'
		when 'na' 		then return 'NA1'
		when 'oce' 		then return 'OC1'
		when 'ru' 		then return 'RU'
		when 'tr'		then return 'TR1'

exports.findChampion = (id, callback) ->
	Champion.findOne {id: id}, (e, champion) ->
		if e
			log.error e
			callback {success: false, message: e}
		if champion
			callback {success: true, champion: champion}
		else
			callback {success: false, message: 'Champion not found.'}

exports.roleScores = (summoner, callback) ->
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
			for mastery in summoner.championMasteries 				# loop through all saved champion masteries
				for champion in champions 							# loop through all champions to find matching one
					if champion.id == mastery.championId			# found champion
						for tag in champion.tags					# loop through champion tags and assign score
							roles[tag] += mastery.championPoints
			callback {success: true, roles: roles}
		else
			callback {success: false, message: 'No champions found in database.'}