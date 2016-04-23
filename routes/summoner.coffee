bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/routes/summoner'}
summonerModule 			= require '../modules/summoner'

module.exports = (router) ->
	router.route('/summoner/:region/:key')
	.get (req, res) ->
		summonerModule.find {
			key 		: req.params.key
			region 		: req.params.region
		}, (r) ->
			res.json r

	router.route('/summoners')
	.get (req, res) ->
		Summoner.find {}, (e, summoners) ->
			if e
				log.error e
			else if summoners.length > 0
				res.json summoners
			else res.json {message: 'No summoners saved.'}

	router.route('/best')
	.get (req, res) ->
		Summoner.find {}, (e, summoners) ->
			if e
				log.error e
			if summoners.length > 0
				best = []
				for mastery in summoners[0].championMasteries
					if mastery.championLevel == 5
						best.push mastery
				res.json best
			else res.json {message: 'No entries found.'}

	return router