module.exports = (grunt) ->

    fs = require 'fs'
    _ = require 'underscore'
    exec = (require 'child_process').exec

    tmpBuildDir = "#{__dirname}/.build";

    grunt.initConfig
        pkg: grunt.file.readJSON("package.json")
        requirejs:
            compile:
                options:
                    baseUrl: "public/js/",
                    dir: "<%=deploy.buildDir%>",
                    optimize: "uglify",
                    stubModules: ['cs', 'coffee-script'],
                    keepBuildDir: true,
                    skipDirOptimize: true,
                    pragmasOnSave:
                        excludeCoffeeScript: true
                    modules: [
                        {name: "layout"}
                    ]
        concat:
            libs:
                src: _.map([
                        "jquery.min.js",
                        "require.js",
                        "*.js"
                        ], (i)->
                            'public/js/libs/' + i
                    )
                dest: "<%=deploy.buildDir%>/libs.js"


    grunt.loadNpmTasks "grunt-requirejs"
    grunt.loadNpmTasks "grunt-contrib-concat"

    grunt.loadTasks "./grunt/"

    grunt.registerTask "prepare-build", "Prepare build", ()->
        done = this.async()
        exec "rm -Rf #{tmpBuildDir.replace(/(["\s'$`\\])/g,'\\$1')}", (err, stdout, stderr)->
            if err then return done(err)
            fs.mkdirSync(tmpBuildDir)
            grunt.config.set("deploy.buildDir", tmpBuildDir)
            done()

    grunt.registerTask "cleanup-build", "Cleanup after build", ()->
        done = this.async()
        exec "rm -Rf #{tmpBuildDir.replace(/(["\s'$`\\])/g,'\\$1')}", (err, stdout, stderr)->
            if err || stderr
                grunt.log.error('Error removing tmpBuildDir')
                return done(false)
            return done()

    grunt.registerTask "build", ["prepare-build", "requirejs", "concat", "freeze-static", "cleanup-build"]