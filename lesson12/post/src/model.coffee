###
#
# model.coffee
#
###

odme = require('odme')
_ 	    = require "lodash"

module.exports = (options) ->
	class Post extends odme.CB
		search: (query, cb) ->
			cb options.searchEng.search(query)
		source: options.db
		props:
			title: on
			body: on
			author_key: on
			no: on
		PREFIX: 'p'

		getPost: (key, cb) ->
			@get(key).then (post) ->
				cb(null, post)

		getPosts: (size, from, user_mail, cb) ->
			query =
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
			name = (result) ->
				console.log result
			@search query, (searched) ->
				searched.then (docs) ->
					console.log docs

		getPostsOf: (email, size, from, cb) ->
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

		getRandomPosts: (rands, cb) ->
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

