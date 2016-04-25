bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/routes/summoner'}
summonerModule 			= require '../modules/summoner'

module.exports = (router) ->
	router.route('/summoner/n/:region/:key')
	.get (req, res) ->
		summonerModule.redirectToProper {
			key: req.params.key
			region: req.params.region
		}, (r) ->
			res.redirect '/summoner/' + r.summoner.region + '/' + r.summoner.id

	router.route('/summoner/:region/:id')
	.get (req, res) ->
		summonerModule.find {
			id: req.params.id
			region: req.params.region
		}, (r) ->
			res.render 'summoner.pug', r

	router.route('/summoners')
    .get (req, res) ->
		Summoner.find {}, (e, summoners) ->
			if e
				log.error e
			else if summoners.length > 0
				res.json summoners
			else res.json {message: 'No summoners saved.'}

	return router