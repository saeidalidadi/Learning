module.exports = [{

	path: '/register'
	method: ['GET', 'POST']
	config:
		auth: { mode: 'try' }
  handler: require './register'
}
,
{
	path: '/login'
	method: ['GET', 'POST']
	config:
		auth: { mode: 'try' }
	handler: require './login'
}
,
{
	path: '/me'
	method: 'GET'
	handler: require "./profile"
}
,
{
	path: '/logout'
	method: ['GET', 'POST']
	config:
		auth: { mode: 'try' }
	handler: require "./logout"
}]
