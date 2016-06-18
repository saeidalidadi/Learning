###
#
# one-post.coffee
# Method: GET
# Path: /posts/{post_key}
# Des: will show just one post age
#
###


module.exports = (request, reply, options) ->
  options.model::getPost request.params.post_key, (err, post) ->
    reply.view "post", { post: post.doc }
