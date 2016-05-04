bunyan 				= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/routes/index'}
indexModule = require '../modules/index'

module.exports = (router) ->
	router.route('/')
	.get (req, res) ->
		res.render 'home'
	.post (req, res) ->
		key = req.body.key.toLowerCase().replace ' ', ''
		region = req.body.region.toLowerCase().replace ' ', ''
		res.redirect '/summoner/' + region + '/' + key

	router.route('/champions')
	.get (req, res) ->
		Champion.find {}, (e, champions) ->
			if e
				log.error e
			res.json champions

	router.route('/gib/:region/:id')
	.get (req, res) ->
		indexModule.gib {id: req.params.id, region: req.params.region}, (r) ->
			res.json r

	return router
