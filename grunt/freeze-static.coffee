module.exports = (grunt)->

    fs = require 'fs'
    async = require 'async'
    borschikPath = "node_modules/borschik/bin/borschik"
    exec = (require 'child_process').exec

    outDir = "public/opt"

    processDir = (inDir, outDir, tech, callback)->
        exec "rm -Rf #{outDir}", (err, stdout, stderr)->
            if err then return callback(err)
            exec "mkdir #{outDir}", (err, stdout, stderr)->
                if err then return callback(err)
                files = fs.readdirSync inDir
                async.forEach(
                    files
                    , (file, callback)->
                        stat = fs.statSync("#{inDir}/#{file}")
                        if not stat.isFile()
                            return callback()
                        exec "#{borschikPath} -i #{inDir}/#{file} -t #{tech} > #{outDir}/#{file}", (err, stdout, stderr)->
                            if err then return callback(err)
                            if stderr then return callback(new Error(stderr))
                            return callback()
                    , callback
                )

    grunt.registerTask "freeze-static", "Freeze all static", ->
        done = this.async()
        exec "rm -Rf #{outDir}", (err, stdout, stderr)->
            if err then return done(err)
            exec "mkdir #{outDir}", (err, stdout, stderr)->
                if err then return done(err)
                processDir "public/css", "#{outDir}/css", "css", (err)->
                    if err then return done(err)
                    exec "ln -sf '../public/img' '.build/img'", (err, stdout, stderr)->
                        if err then return done(err)
                        processDir ".build", "#{outDir}/js", "js-link", (err)->
                            if err then return done(err)
                            exec "#{borschikPath} freeze -i public > #{outDir}.json", (err, stdout, stderr)->
                                if err then return done(err)
                                return done()