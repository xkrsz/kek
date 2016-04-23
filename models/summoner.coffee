mongoose 		= require 'mongoose'
Schema 			= mongoose.Schema

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
}