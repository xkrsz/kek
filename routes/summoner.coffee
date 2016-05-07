bunyan = require 'bunyan'
log = bunyan.createLogger {name: 'kek/routes/summoner'}
summonerModule = require '../modules/summoner'

module.exports = (router) ->
	router.route('/summoner/:region/:key')
	.get (req, res) ->
		summonerModule.updateSummoner {
			key: req.params.key
			region: req.params.region
		}, (r) ->
			if r.success
				res.render 'summoner.pug', r
			else
				res.json r

	router.route('/summoners')
	.get (req, res) ->
		Summoner.find {}, 'identity', (e, summoners) ->
			if e
				log.error e
			else if summoners.length > 0
				res.json summoners
			else res.json {message: 'No summoners saved.'}

	return router
