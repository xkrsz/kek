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


	return router