mongoose 		= require 'mongoose'
Schema 			= mongoose.Schema

ChampionMastery = new Schema {
	championId 		:
		type 			: Number
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

module.exports = mongoose.model 'summoner', new Schema {
	id				:
		type 			: Number
		unique			: true
	name			:
		type			: String
	key 			:
		type			: String
	region 			:
		type			: String
	summonerLevel 	:
		type			: Number
	profileIconId	:
		type			: Number
	createdAt		:
		type			: Date
	updateAt		:
		type			: Date
	championMasteries: [ChampionMastery]
}