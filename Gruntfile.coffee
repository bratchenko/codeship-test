module.exports = (grunt) ->

    fs = require 'fs'
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

    grunt.loadNpmTasks "grunt-requirejs"

    grunt.registerTask "prepare-build", "Prepare build", ()->
        if !fs.existsSync(tmpBuildDir)
            fs.mkdirSync(tmpBuildDir)
        grunt.config.set("deploy.buildDir", tmpBuildDir)

    grunt.registerTask "cleanup-build", "Cleanup after build", ()->
        done = this.async()
        exec "rm -Rf #{tmpBuildDir.replace(/(["\s'$`\\])/g,'\\$1')}", (err, stdout, stderr)->
            if err || stderr
                grunt.log.error('Error removing tmpBuildDir')
                return done(false)
            return done()

    # Top-level tasks
    grunt.registerTask "build", ["prepare-build", "cleanup-build"]