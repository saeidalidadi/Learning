###
#
#	update-page.coffee
#	Method: GET
#	Path: /update/{post_key}
#	Des: will reply the post as a editable content
#
###

module.exports = (request, reply) ->
	model = options.model
	model.getPost request.params.doc_key, (err, post) ->
		reply.view "update", { post: post.doc, token: request.auth.token }
