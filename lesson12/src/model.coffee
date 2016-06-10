puffer  = require "puffer"
odme 	  = require "odme"
elastic = require "elasticsearch"
config  = require "./config"
_ 	    = require "lodash"

db = new puffer { port: config.database.port, host: config.database.host, name: 'default' }

searchEng = new elastic.Client({
	host: "localhost:#{config.elastic.port}"
	#log: 'trace'
})

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
	_index: 'blog'
	@searchEng: searchEng
	
	_mergeAuthor: (posts, users) ->

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

	@getPost: (key, cb) ->
		Post.get(key).then (post) ->
			cb(null, post)

	@getPosts: (size, from, user_mail, cb) ->
		searchEng.search({
			index: 'blog'
			type: 'posts'
			body:
				size: size
				from: from
				sort: [{
					no: order: "asc"
				}]
				query:
					match_all: {}
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
									if user_mail?
										if user._source.doc.email isnt user_mail
											delete post.doc_key
						cb(null, posts)
	
	@getPostsOf: (email, size, from, cb) ->
		@searchEng.search({
			index: @_index
			type: 'users'
			body:
				query:
					term:
						email: email
		}).then (user) =>
			author_key = user.hits.hits[0]._source.doc.doc_key
			@searchEng.search({
				index: 'blog'
				type: 'posts'
				body:
					size: size
					from: from
					sort: [{
						no: order: "asc"
					}]
					query:
						match:
							author_key: author_key
			}).then (posts) ->
				doc_keys = _.map posts.hits.hits, (post) ->
					post._source.doc.doc_key
				Post.get(doc_keys).then (docs) ->
					ps = _.map docs, (p) ->
						p.doc
					cb(null, ps)

	@getRandomPosts: (rands, cb) ->
		@searchEng.search({
			index: 'blog'
			type: 'posts'
			body:
				query: terms: no: rands
		}).then (docs) ->
			posts = _.map docs.hits.hits, (doc) ->
				doc._source.doc
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
	@updatePost: (updated, key, cb) ->
		Post.get(key).then (post) ->
			post.doc.title = updated.title
			post.doc.body = updated.body
			post.update()
			cb(null, true)

	@deletePost: (key, cb) ->
		Post.remove(key).then (d) ->
			console.log d
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
	@countPosts: (email, cb) ->
		if email?
			@searchEng.search({
				index: 'blog'
				type: 'users'
				body:
					query:
						term: email: email
			}).then (result) =>
				author_key = result.hits.hits[0]._source.doc.doc_key
				@searchEng.search({
					index: 'blog'
					type: 'posts'
					body:
						size: 0
						query:
							match: author_key: author_key
				}).then (doc) ->
					cb doc.hits.total
		else
			@searchEng.search({
				index: 'blog'
				type: 'posts'
				body:
					size: 0
					query:
						match_all: {}
			}).then (d) ->
				cb d.hits.total
