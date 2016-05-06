mongoose 		= require 'mongoose'
Schema 			= mongoose.Schema

ChampionRanked = new Schema {
	id: Number
	stats:
		totalSessionsPlayed: Number
		totalSessionsLost: Number
		totalSessionsWon: Number
		totalChampionKills: Number
		totalDeathsPerSession: Number # this is NOT a number of deaths per game, but a TOTAL amount of deaths. Naming in API is wrong and I just want to keep variables intact.
		totalAssists: Number
		totalMinionKills: Number
		totalGoldEarned: Number
		maxChampionsKilled: Number
		maxNumDeaths: Number
}

ChampionMastery = new Schema {
	championId 		:
		type 			: Number
	championName 	:
		type			: String
	championKey 	:
		type			: String
	championLevel 	:
		type 			: Number
	championPoints 	:
		type 			: Number
	championPointsSinceLastLevel :
		type			: Number
	championPointsUntilNextLevel :
		type			: Number
	chestGranted	:
		type			: Boolean
	highestGrade 	:
		type 			: String
}

Summoner = new Schema {
	identity		:
		id				:
			type 			: Number
		name			:
			type			: String
		key 			:
			type			: String
		region 			:
			type			: String
		platform 		:
			type 			: String
		summonerLevel 	:
			type			: Number
		profileIconId	:
			type			: Number
		updatedAt	 	: Date
	data			:
		championMastery	:
			totalPoints 	: Number
			champions		: [ChampionMastery]
			rolesPoints		:
				Assassin 		: Number
				Fighter 		: Number
				Mage 				: Number
				Marksman 		: Number
				Support 		: Number
				Tank 			: Number
			updatedAt		: Date
		statsRanked		:
			champions 		: [ChampionRanked]
			updatedAt 		: Date
		league 			:
			name 			: String
			tier 			: String
			division 		: String
			leaguePoints 	: Number
			wins 			: Number
			losses 			: Number
			updatedAt		: Date
	createdAt		: Date
	updatedAt 		: Date
}

module.exports = mongoose.model 'summoner', Summoner
