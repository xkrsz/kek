bunyan = require 'bunyan'
log = bunyan.createLogger {name: 'kek/routes/ranking'}

module.exports = (router) ->
	router.route('/ranking')
	.get (req, res) ->
		res.render 'ranking.pug'

	return router