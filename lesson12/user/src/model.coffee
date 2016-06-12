###
#
#	model.coffee
#	Base Class: Model
#
###

class User extends Model
	source: db
	props:
		name: on
		email: on
		password:	on
		posts: on
	PREFIX: 'u'

	@isRegistered: (email, cb) ->
		searchEng.search({
			index: 'blog'
			type: 'users'
			body:
				query:
					match: { email: email }
		}).then (doc) ->
			if doc.hits.total is 1 and email is  doc.hits.hits[0]._source.doc.email
				cb(true, doc.hits.hits[0]._source.doc)
			else cb(false)

	@setUser: (user, cb) ->
		user = new User user
		user.create(true).then (d) ->
			cb(true)

	@getUser: (email, cb) ->
		@searchEng.search({
			index: 'blog'
			type: 'users'
			body:
				query:
					term: email: email
		}).then (user) ->
			cb null, user.hits.hits[0]._source.doc


