bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/routes/api-summoner'}
summonerModule 			= require '../modules/summoner'

module.exports = (router) ->
	router.route('/api/summoner/champion-mastery/:region/:id')
	.get (req, res) ->
		summonerModule.getChampionMasteries {id: req.params.id, region: req.params.region}, (r) ->
			res.json r

	router.route('/api/summoner/overview/:region/:id')
	.get (req, res) ->
		summonerModule.apiSummonerOverview {id: req.params.id, region: req.params.region}, (r) ->
			if r.reload
				res.redirect '/api/summoner/overview/' + req.params.id + '/' + req.params.region
			else
				res.json r

	return router