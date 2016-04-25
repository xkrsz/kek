mongoose 		= require 'mongoose'
Schema 			= mongoose.Schema

ChampionMastery = new Schema {
	championId 		:
		type 			: Number
	championName 	:
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
		createdAt 		: Date
		updatedAt	 	: Date
	data			:
		championMastery	:
			totalPoints 	: Number
			champions		: [ChampionMastery]
			rolesPoints		:
				Assassin 		: Number
				Fighter 		: Number
				Mage 			: Number
				Marksman 		: Number
				Support 		: Number
				Tank 			: Number
			createdAt 		: Date
			updatedAt		: Date
	createdAt		: Number
	updatedAt 		: Number
}
Summoner.index {id: 1, region: 1}, {unique: true}

module.exports = mongoose.model 'summoner', Summoner