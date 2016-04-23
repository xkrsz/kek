mongoose 		= require 'mongoose'
Schema 			= mongoose.Schema

module.exports = mongoose.model 'champion', new Schema {
	id 			:
		type 		: Number
	key 		:
		type 		: String
	name 		:
		type		: String
	title 		:
		type 		: String
	tags		:
		type 		: []
}