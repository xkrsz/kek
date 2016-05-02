bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/routes/api-ranking'}
rankingModule 			= require '../modules/ranking'

module.exports = (router) ->
  router.route('/api/ranking/overall')
  .get (req, res) ->
    rankingModule.apiRankingOverall (r) ->
      res.json r

  return router
