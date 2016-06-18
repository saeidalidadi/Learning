###
#
# delete-post.coffee
# Method: GET
# Path: /posts/{post_key}
# Des: delete a post with post_key for a user
#
###

module.exports = (request, reply, options) ->
  options.model::deletePost request.params.post_key, (err, result) ->
    reply 'Your post deleted'
