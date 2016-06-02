puffer  = require "puffer"
odme 	  = require "odme"
elastic = require "elasticsearch"
config  = require "./config"
_ 	    = require "lodash"

db = new puffer { port: config.database.port, host: config.database.host, name: 'default' }

searchEng = new elastic.Client { host: "localhost:#{config.elastic.port}" }

class User extends odme.CB
	source: db
	props:
		name: true
		email: true
		password: true
		posts: true
	PREFIX: 'u'

class Post extends odme.CB
	source: db
	props:
		title: true
		author: true
		body: true
	PREFIX: 'p'


module.exports = class model
	constructor:  () ->
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

	@getPosts: (from, to, cb) ->
		searchEng.search({
			index: 'blog'
			type: 'posts'
			body:
				query:
					range:
						no: { gte: from, lte: to }
		}).then (docs) ->
			if docs.hits.total isnt 0
				keys = for doc in docs.hits.hits
					doc._id
				Post.find(keys,'title,body,author_key').then (posts) ->
					# Extract all uniq author keys from posts
					auth_keys = _.uniq(_.map posts, (post) ->
						return post.author_key
					)
					
					# For all keys from pre get users from elastic
					searchEng.search({
						index: 'blog'
						type: 'users'
						body:
							query:
								terms:
									doc_key: auth_keys
					}).then (users) ->
						# Merge name field from users to posts
						for post in posts
							for user in users.hits.hits
								if post.author_key is user._id
									post.author = user._source.doc.name

						cb(null, posts)

	@setPost: (post, cb) ->
		# Search for post.email in users
		# Add returned user key to post doc
		# Create this post in couchbase post docs
		post = new Post { title: post.title, body: post.body, author_key:'' }

	@setUser: (user, cb) ->
		user = new User user
		user.create(true).then (d) ->
			cb(true)

	@getUser: (cb) ->
		
