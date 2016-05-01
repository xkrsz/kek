bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/routes/api-summoner'}
summonerModule 			= require '../modules/summoner'

module.exports = (router) ->
	router.route('/api/summoner/overview/:region/:id')
	.get (req, res) ->
		summonerModule.apiSummonerOverview {id: req.params.id, region: req.params.region}, (r) ->
			res.json r

	router.route('/api/summoner/champions/:region/:id')
	.get (req, res) ->
		summonerModule.apiSummonerChampions {id: req.params.id, region: req.params.region}, (r) ->
			res.json r

	router.route('/api/summoner/league/:region/:id')
	.get (req, res) ->
		summonerModule.apiSummonerLeague {id: req.params.id, region: req.params.region}, (r) ->
			res.json r

	return router