should   = require('chai').should()
chai     = require('chai')
chaiHttp = require('chai-http')

chai.use chaiHttp

api = 'localhost:8012'

describe 'Post', ->
	context 'GET /', ->
		it 'Should return a page that contains atmost 5 and atleast 1 post', (done) ->
			chai.request(api)
				.get('/')
				.end (err, res) ->
					if err then done(err)
					res.should.have.status(200)
					done()
	context 'GET /post/{post_key}', ->
		it 'Should return a page that contains just one post', (done) ->
			chai.request(api)
				.get('/posts/bp_test')
				.end (err, res) ->
          console.log res.text
					res.should.be.html
					done()
	context 'GET /posts?size={Integer}', ->
		it 'Should return a page contains at least five post and', (done) ->
			chai.request(api)
				.get('/posts?size=0')
				.end (err, res) ->
					done()
