should  = require('chai').should()
elastic = require('elasticsearch')
puffer  = require('puffer')

db = new puffer { port: 8091, host: 'localhost', name: 'default' }
searchEng = new elastic.Client { host: "localhost:9200" }

PM  = require("../src/model") { db: db, searchEng: searchEng }

sample_post =
	title: 'This is a test title'
	body: 'test for post model, test for post model, test for post model'
	author_email: 'saeid@me.com'
	key: 'p_testkey'

describe 'Post', () ->
	context 'setPost', () ->
		it 'Should return true if post adding was successful', (done) ->
			PM::setPost sample_post, (err, result) ->
				if err then done(err)
				result.should.be.true
				done()

	context 'getPost', ->
		it 'Should return a post with body title and other props', (done) ->
			PM::getPost sample_post.key, (err, result) ->
				if err then done(err)
				result.should.have.property('doc')
				result.doc.title.should.be.equal(sample_post.title)
				result.doc.body.should.be.equal(sample_post.body)
				done()

	context 'getPosts', ->
		it 'Should return 5 posts', (done)->
			PM::getPosts 5, 0, 'saeid@me.com', (err, result) ->
				if err then done(err)
				result.should.have.length.at.most(5)
				result.should.have.length.at.least(1)
				done()

	context 'getPostsOf', ->
		it 'Should return posts of a user', (done) ->
			PM::getPostsOf 'saeid@me.com', 5, 0, (err, result) ->
				if err then done(err)
				result.should.have.length.at.least(1)
				author_key = result[0].author_key
				for one in result
					one.author_key.should.be.equal(author_key)
				done()
