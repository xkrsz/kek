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
				platform 		: 'EUN1' # TODO	
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
					exports.update {
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
exports.update = (summoner, callback) -> # summoner = {id, region, platform}
	log.info 'Updating summoner...'
	request 'https://' + summoner.region + '.api.pvp.net/championmastery/location/' + summoner.platform + '/player/' + summoner.id + '/champions?api_key=' + process.env.KEY, (e, r, b) ->
		if e
			log.error e
		else if r.statusCode == 200
			b = JSON.parse(b)
			log.info 'Got mastery data'
			

