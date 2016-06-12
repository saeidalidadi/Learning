###
#
# update-post.coffee
# Method: PUT
# Path: /post/{post_key}
#
###
model = require "./model"

module.exports = (request, reply) ->
	model.updatePost request.payload, request.params.post_key, (err, result) ->
		if result
			reply('Your post updated')
