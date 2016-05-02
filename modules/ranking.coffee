bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/modules/ranking'}

exports.apiRankingOverall = (callback) ->
	Summoner.find({}, 'identity.name identity.region data.championMastery data.league')
    .sort({"data.championMastery.totalPoints": -1}).exec (e, cachedSummoners) ->
		if e
			log.error e
		if cachedSummoners.length
			log.info 'apiRankingOverall: Found summoners in datbase.'
			summoners = []

			for summoner in cachedSummoners
				summoner = summoner.toObject()
				summoners.push {
					name: summoner.identity.name
					totalPoints: summoner.data.championMastery.totalPoints
					role: Object.keys(summoner.data.championMastery.rolesPoints)[0]
					tier: summoner.data.league.tier
					division: summoner.data.league.division
					winrate: Number((summoner.data.league.wins / (summoner.data.league.wins + summoner.data.league.losses)).toFixed(2))
					games: summoner.data.league.wins + summoner.data.league.losses
				}
			callback {
				success: true
				summoners: summoners
			}
		else
			log.error 'apiRankingOverall: No summoners saved in database.'
			callback {
				success: false
				message: 'No summoners found in database.'
			}
