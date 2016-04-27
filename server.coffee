# Dependencies
express					= require 'express'
app 					= express()
router 					= express.Router()
http 					= require('http').Server(app)
bodyParser 				= require 'body-parser'
pug 					= require 'pug'
bunyan 					= require 'bunyan'
log 					= bunyan.createLogger {name: 'kek'}
mongoose 				= require 'mongoose'
request 				= require 'request'

# Express config
app.set 'view engine', 'pug'
app.use bodyParser.urlencoded {extended: true}
app.use bodyParser.json()
port = process.env.PORT || 3000

mongouri = process.env.MONGOURI || 'mongodb://localhost/kek'
mongoose.connect mongouri
db = mongoose.connection
db.on 'error', ->
	log.error 'Database connection error.'
db.once 'open', ->
	log.info 'Connected to database!'

# Models
global.Summoner = require './models/summoner'
global.Champion = require './models/champion'

# Routes
app.use '/', require('./routes/index')(router)
app.use '/', require('./routes/summoner')(router)
app.use '/', require('./routes/api-summoner')(router)

# Static files
app.use '/static', express.static('public')

# Initial jobs
request 'https://global.api.pvp.net/api/lol/static-data/eune/v1.2/champion?champData=tags&api_key=' + process.env.KEY, (e, r, b) ->
	if e
		log.error e
	else
		if r.statusCode == 200
			log.info 'Got champions'
			b = JSON.parse(b)
			champions = []

			for champion of b.data
				if b.data.hasOwnProperty champion
					champions.push b.data[champion]
			Champion.remove {}, (e) ->
				if e
					log.error e
				Champion.create champions, (e, champions) ->
					if e
						log.error e
					if champions
						log.info 'Champions saved.'

# Server listener
http.listen port, ->
	log.info 'Listening on port ' + port + '...'