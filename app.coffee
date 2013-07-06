express  = require 'express'
flash    = require 'connect-flash'
manifest = require './package.json'
mongoose = require 'mongoose'
path     = require 'path'
routes   = require './routes'


APP_HOST_ADDRESS     = process.env.HOST || "0.0.0.0"
APP_PORT_NUMBER      = process.env.PORT || 3000
APP_MONGODB_URL      = process.env.MONGOLAB_URI || 'mongodb://'+APP_HOST_ADDRESS+'/'+manifest.name

app = module.exports = express()


## Configuration

app.configure ->
  app.set 'port', APP_PORT_NUMBER
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.logger()
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.methodOverride()
  app.use express.session
    secret: 'bmjhack'
  app.use flash()
  app.use app.router
  app.use express.static path.join(__dirname, "public")


app.configure 'development', ->
  app.set 'connstr', APP_MONGODB_URL+'-dev'
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

app.configure 'production', ->
  app.set 'connstr', APP_MONGODB_URL
  app.use express.errorHandler
    dumpExceptions: false
    showStack: false

## MongoDB

db = mongoose.connection
db.on 'error', (console.error.bind console, 'connection error: ')
db.on 'open', -> console.log 'Connected to '+(app.get 'connstr')
mongoose.connect app.get 'connstr'

app.get '/', (req, res) -> res.render 'index.jade',
  title: 'Open Access Button'

app.get '/add', routes.Event.add

## Run the server

app.listen (app.get 'port'), -> console.log 'Listening on :' + app.get 'port'