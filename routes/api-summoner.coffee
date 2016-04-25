bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/routes/api-summoner'}
summonerModule 			= require '../modules/summoner'

module.exports = (router) ->
	router.route('/api/summoner/mastery-data/:region/:id')
	.get (req, res) ->
		summonerModule.getChampionMasteries {id: req.params.id, region: req.params.region}, (r) ->
			res.json r

	return router