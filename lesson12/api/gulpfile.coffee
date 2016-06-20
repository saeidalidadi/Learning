gulp    = require 'gulp'
exec    = require('child_process').exec
nodemon = require 'gulp-nodemon'
coffee  = require 'gulp-coffee'
plugins = require('./src/config').plugins

gulp.task('api:setup', (cb) ->
  cmds = for plugin in plugins
    "cd ../#{plugin} && npm install && npm link && cd ../api && npm link #{plugin}"
  cmds = cmds.join ' && '
  exec cmds, (err, stdout, stderr) ->
    console.log stdout
    console.log stderr
    cb err
)

gulp.task('api:start', (cb) ->
  nodemon({
    script: 'src/server.coffee'
    ext: 'coffee jade'
    watch: [__dirname, "#{__dirname}/../user/src", "#{__dirname}/../post/src"]
  })
)

gulp.task('build', (cb) ->
  gulp.src('./src/*.coffee')
  .pipe coffee({ bare: true })
  .pipe gulp.dest('./build')
)

gulp.task('default', ['start'])

