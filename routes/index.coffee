bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/routes/index'}

module.exports = (router) ->
	router.route('/')
	.get (req, res) ->
		res.json {success: true}

	return router