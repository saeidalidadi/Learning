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
		body: true
		author_key: true
		no: true
	PREFIX: 'p'


module.exports = class model
	
	@searchEng: searchEng

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

	@getPosts: (from, to, user_mail, cb) ->
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
				Post.find(keys,'title,body,author_key,doc_key').then (posts) ->
					auth_keys = _.uniq(_.map posts, (post) ->
						return post.author_key
					)
					
					searchEng.search({
						index: 'blog'
						type: 'users'
						body:
							query:
								terms:
									doc_key: auth_keys
					}).then (users) ->
						for post in posts
							for user in users.hits.hits
								if post.author_key is user._id
									post.author = user._source.doc.name
									if user._source.doc.email isnt user_mail
										delete post.doc_key


						cb(null, posts)

	@setPost: (post, cb) ->
		t = @
		searchEng.search({
			index: 'blog'
			type: 'users'
			body:
				query:
					term:
						email: post.author_email
		}).then (doc) ->
			key = doc.hits.hits[0]._id
			t.countPosts((all, lastPostNo) ->
				post = new Post { title: post.title, body: post.body, author_key: key, no: ++lastPostNo }
				post.create(true).then (d) ->
					cb(null, true)
			)

	@setUser: (user, cb) ->
		user = new User user
		user.create(true).then (d) ->
			cb(true)

	@getUser: (cb) ->
	@countPosts: (cb) ->
		@searchEng.search({
			index: 'blog'
			type: 'posts'
			body:
				size: 0
				aggs:
					max_no:
						max: { field: "no" }
		}).then (d) ->
			cb d.hits.total, d.aggregations.max_no.value
