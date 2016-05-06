bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek/modules/ranking'}

exports.apiRankingOverall = (callback) ->
	Summoner.find({}, 'identity.name identity.region identity.key data.championMastery data.league')
    .sort({"data.championMastery.totalPoints": -1}).exec (e, cachedSummoners) ->
		if e
			log.error e
		if cachedSummoners.length
			log.info 'apiRankingOverall: Found summoners in datbase.'
			summoners = []

			for summoner in cachedSummoners
				summoner = summoner.toObject()
				try
					summoners.push {
						name: summoner.identity.name
						key: summoner.identity.key
						region: summoner.identity.region
						totalPoints: summoner.data.championMastery.totalPoints
						role: Object.keys(summoner.data.championMastery.rolesPoints)[0]
						tier: summoner.data.league.tier
						division: summoner.data.league.division
						winrate: Number((summoner.data.league.wins / (summoner.data.league.wins + summoner.data.league.losses)).toFixed(2))
						games: summoner.data.league.wins + summoner.data.league.losses
						champion: summoner.data.championMastery.champions[0].championName
						championKey: summoner.data.championMastery.champions[0].championKey
					}
				catch e
					log.error 'apiRankingOverall: ' + e
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

exports.apiRankingChampions = (callback) ->
	Summoner.find {}, 'data.championMastery.champions', (e, cachedSummoners) ->
		if e
			log.error e
		if cachedSummoners.length
			championsPoints = {}
			for cachedSummoner in cachedSummoners
				for cachedChampion in cachedSummoner.data.championMastery.champions
					if championsPoints[cachedChampion.championName]
						championsPoints[cachedChampion.championName] += cachedChampion.championPoints
					else
						championsPoints[cachedChampion.championName] = cachedChampion.championPoints

			Champion.find {}, (e, cachedChampions) ->
				if e
					log.error e
				if cachedChampions.length
					champions = []
					for key of championsPoints
						for champion in cachedChampions
							if champion.name == key
								champions.push {
									name: key
									key: champion.key
									points: championsPoints[key]
								}
					champions.sort (a, b) -> b.points - a.points

					callback {
						success: true
						champions: champions
					}
				else
					log.error 'apiRankingChampions: No champions found in databse.'
					callback {
						success: false
						message: 'No champions found in database, something\'s wrong.'
					}
