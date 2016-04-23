bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/modules/summoner'}
request 				= require 'request'

exports.find = (summoner, callback) ->
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
			b = JSON.parse(b)[key]
			log.info {summoner: b}, 'Got summoner.'
			summoner = {
				key 			: summoner.key
				name 			: b.name
				id 				: b.id
				profileIconId	: b.profileIconId
				summonerLevel 	: b.summonerLevel
			}
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