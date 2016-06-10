###
#
#	one-post.coffee
#	Method: GET
#	Path: /posts/{post_key}
#	Des: will show just one post age
#
###

model = require "./model"

module.exports = (request, reply) ->
	model.getPost(request.params.post_key, (err, post) ->
		reply.view "post", { post: post.doc }
	)
