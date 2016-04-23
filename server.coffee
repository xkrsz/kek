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

# Routes
app.use '/', require('./routes/index')(router)
app.use '/', require('./routes/summoner')(router)

# Server listener
http.listen port, ->
	log.info 'Listening on port ' + port + '...'