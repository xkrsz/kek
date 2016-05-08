bunyan = require 'bunyan'
log = bunyan.createLogger {name: 'kek/routes/ranking'}

module.exports = (router) ->
	router.route('/ranking')
	.get (req, res) ->
		res.render 'ranking.pug'

	router.route('/ranking/role/:role')
	.get (req, res) ->
		res.render 'ranking-role.pug'

	router.route('/ranking/champion/:champion')
	.get (req, res) ->
		res.render 'ranking-champion.pug'

	router.route('/ranking/champions')
	.get (req, res) ->
		res.render 'ranking-champions.pug'

	router.route('/rankings')
	.get (req, res) ->
		res.render 'rankings.pug'

	return router
