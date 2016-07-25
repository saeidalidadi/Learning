Hapi = require "hapi"
Odme = require "odme"
elastic = require "elasticsearch"

db = new require("puffer") { port: 8091, name: 'default', host: 'localhost' }

class Post extends Odme.CB
	source: db
	props:
		title: true
		body: true
 
server = new Hapi.Server()

server.connection { port: 8080, host: 'localhost' }

server.register([require('inert'), require('vision'), require('lout')], (err) ->

	server.route([{
		path: '/'
		method: 'GET'
		handler: (request, reply) ->
			reply 'Ok'
	}
	,
	{
		path: '/posts/{post_key}'
		method: 'GET'
		handler: (request, reply) ->
			Post.get(request.params.post_key).then (result) ->
				reply("title: #{result.doc.title}<br>Author: #{result.doc.author}<br>#{result.doc.body}")
	}
	,
	{
		path: '/posts'
		method: 'POST'
		handler: (request, reply) ->

			post = new Post({
				title: request.payload.title
				body: request.payload.body
				author: request.payload.author
				created_at: request.payload.created_at
			})
			
			post.create(true).then () ->
				reply("Published a post as:  #{request.payload.title}")
	}
	,
	{
		path: '/posts'
		method: 'GET'
		handler: (request, reply) ->

			# Query search to elastic for all posts
			client = new elastic.Client { host: 'localhost:9200'}
			client.search({
				idex: 'blog'
				type: 'posts'

			}).then (docs) ->

				# Getting doc_key fields from result
				keys = for doc in docs.hits.hits
					doc._source.doc.doc_key

				# Getting all documents with doc_key from pre step as a bulk request to couchbase
				Post.get(keys).then (posts) ->
					reply(posts)
	}
	,
	{
		path: '/posts/{post_key}'
		method: 'DELETE'
		handler: (request, reply) ->
			Post.remove(request.params.post_key).then (result) ->
				reply(result)
	}
	,
	{
		path: '/posts/{post_key}'
		method: 'PUT'
		handler: (request, reply) ->
			Post.get(request.params.post_key).then (post) ->
				payload = request.payload
				if payload.title
					post.doc.title = payload.title
				if payload.body
					post.doc.body = payload.body
				if payload.author
					post.doc.author = payload.author
				if payload.created_at
					post.doc.created_at = payload.created_at
				post.doc.doc_key = request.params.post_key
				post.update().then (result) ->
					reply(result)
	}])
	
	server.start((err) ->
		console.log "Server running at: #{server.info.uri}"
	)
)

