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

exports.apiRankingRole = (role, callback) ->
	role = role.toLowerCase()
	role = role.charAt(0).toUpperCase() + role.slice(1)

	if role == 'Assassin' || role == 'Fighter' || role == 'Mage' ||
	role == 'Marksman' || role == 'Support' || role == 'Tank'
		sort = {}
		sort['data.championMastery.rolesPoints.' + role] = -1
		Summoner.find({}, 'identity.name identity.region data.championMastery.rolesPoints.' + role +
		' data.championMastery.champions data.league').sort(sort).exec (e, cachedSummoners) ->
			if e
				log.error e
			if cachedSummoners.length
				summoners = []
				for summoner in cachedSummoners
					try
						games = summoner.data.league.wins + summoner.data.league.losses
						summoners.push {
							name: summoner.identity.name
							region: summoner.identity.region
							points: summoner.data.championMastery.rolesPoints[role]
							championName: summoner.data.championMastery.champions[0].championName
							championKey: summoner.data.championMastery.champions[0].championKey
							tier: summoner.data.league.tier
							division: summoner.data.league.division
							games: games
							winrate: Number((summoner.data.league.wins / games).toFixed(2))
						}
					catch e
						log.error e
				if summoners.length
					callback {
						success: true
						summoners: summoners
					}
				else
					callback {
						success: false
						message: 'nope'
					}
	else
		callback {
			success: false
			message: 'Wrong role provided.'
		}

exports.apiRankingChampion = (champion, callback) ->
	champion = champion.toLowerCase()

	Summoner.find {}, 'identity.name identity.region data.championMastery.champions data.league',
	(e, cachedSummoners) ->
		if e
			log.error e
		if cachedSummoners.length
			summoners = []
			for summoner in cachedSummoners
				for cachedChampion in summoner.data.championMastery.champions
					if cachedChampion.championName.toLowerCase().replace(' ', '') == champion
						summoners.push {
							name: summoner.identity.name
							region: summoner.identity.region
							points: cachedChampion.championPoints
							tier: summoner.data.league.tier
							division: summoner.data.league.division
						}

			summoners.sort (a, b) -> b.points - a.points
			if summoners.length
				callback {
					success: true
					summoners: summoners
				}
			else
				callback {
					success: false
					message: 'nope.'
				}
