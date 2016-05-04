bunyan        = require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/routes/api-home'}
homeModule 		= require '../modules/home'

module.exports = (router) ->
  router.route('/api/home/total')
  .get (req, res) ->
    homeModule.total (r) ->
      res.json r

  router.route('/api/home/champions')
  .get (req, res) ->
    homeModule.champions (r) ->
      res.json r

  return router