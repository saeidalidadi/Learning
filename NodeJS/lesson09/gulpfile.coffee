gulp = require "gulp"
nodemon = require "gulp-nodemon"

gulp.task('start', (cb) ->
	nodemon({
		script: 'src/index.coffee'
	})
)
