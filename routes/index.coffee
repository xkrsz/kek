bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/routes/index'}

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

	return router