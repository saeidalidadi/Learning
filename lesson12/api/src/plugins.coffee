model  = require "./model"
config = require "./config"

module.exports = [
	{
		register: require('lout')
		options: auth: mode: 'required'
	}
	{
		register: require('post')
		options:
			db: model.db
			searchEng: model.searchEng
	}
	{
		register: require('user')
		options:
			secretKey: config.tokenKey
			db: model.db
			searchEng: model.searchEng
	}
]

