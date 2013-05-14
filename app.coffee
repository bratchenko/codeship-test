express     = require 'express'

app = module.exports = express()

global.config = require "#{__dirname}/config"

app.configure ()->
    staticMappings = {}
    if global.config.env == 'production'
        staticMappings = JSON.parse((require 'fs').readFileSync "#{__dirname}/public/opt.json")

    app.engine 'html', (require "consolidate").swig
    (require 'swig').init(
        root: "#{__dirname}/tpl"
        allowErrors: true
        filters:
            staticUri: (input)->
                if staticMappings['public/opt' + input]
                    return staticMappings['public/opt' + input]
                if staticMappings['public' + input]
                    return staticMappings['public' + input]
                else
                    return input
    );
    app.set 'view engine', 'html'
    app.set 'views', "#{__dirname}/tpl"

    app.use express.bodyParser()

    app.use express.cookieParser('secret')

    app.use express.cookieSession({
        key: 'sid'
        cookie:
            maxAge: 1000 * 86400 * 365 * 5 # 5 years
    })

    app.use express.static "#{__dirname}/public"

    app.locals.config = global.config

app.get '/', (req, res, nect)->
    res.render 'index'


app.all '*', (req, res, next)->
    if req.url == '/favicon.ico'
        res.send("", 404)
    else
        next(new Error("Not found #{req.url}"))

app.use (err, req, res, next)->
    if err
        console.log(err.stack || err)
        res.status(500)
        res.send(err.stack || err)
    else
        next()

app.listen config.port

console.log "Running site in #{config.env} mode :#{config.port}"