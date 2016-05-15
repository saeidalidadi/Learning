gulp = require "gulp"
nodemon = require "gulp-nodemon"
coffee = require "gulp-coffee"

gulp.task('start', (cb) ->
	nodemon({
		script: 'src/index.coffee'
	})
	.on 'restart', () ->
		console.log "Server restarted"
)

gulp.task('build', (cb) ->
	gulp.src('./src/*.coffee')
	.pipe coffee({ bare: true })
	.pipe gulp.dest('./build')
)

