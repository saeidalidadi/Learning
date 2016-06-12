
module.exports = (base) ->
	class Dog extends base
		setString: (string) ->
			@forTest string, (newst) ->
				console.log newst
###
popy = new Dog 'popy'

console.log popy._getName()
popy._run('wowowow')
console.log popy._name

Dog::running 'dddd', (voice) ->
	console.log voice
###

#Dog::setString 'saeid alidadi'
