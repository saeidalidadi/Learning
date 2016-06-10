###
#
#	delete-post.coffee
#	Method: GET
#	Path: /posts/{post_key}
#	Des: delete a post with post_key for a user
#
###
model = require "./model"

module.exports = (request, reply) ->
	console.log request.params.post_key
	model.deletePost request.params.post_key, (err, result) ->
		reply 'Your post deleted'