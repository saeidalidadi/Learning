test = (string) ->
	prop =
		name: string

module.exports = class Animal
	constructor: (@_name) ->
	forTest: (testString, cb) ->
		cb test testString

	voice: 'oooo'

	running: (voice, cb) ->
		voice = @voice + voice
		cb(voice)
	_run: (runningVoice) ->
		t = @
		@running(runningVoice, (voice) ->
			console.log voice
		)
	_getName: ->
		@_name
	_setname: (name) ->
		@_name = name


