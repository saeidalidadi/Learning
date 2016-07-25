###
#
# update-post.coffee
# Method: PUT
# Auth: Required
# Path: /post/{post_key}
#
###

module.exports = (request, reply, options) ->
  if request.auth.isAuthenticated
    options.model::updatePost request.payload, request.params.post_key, (err, result) ->
      if result
        reply('Your post updated')
