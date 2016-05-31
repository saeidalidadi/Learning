gulp = require "gulp"
nodemon = require "gulp-nodemon"
coffee = require "gulp-coffee"

gulp.task('start', (cb) ->
	nodemon({
		script: 'src/server.coffee'
		ext: 'coffee jade'
	})
)

gulp.task('build', (cb) ->
	gulp.src('./src/*.coffee')
 	.pipe coffee({ bare: true })
  .pipe gulp.dest('./build')
)

gulp.task('default', ['start'])

