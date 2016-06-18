###
#                                              
# posts.coffee                                 
# Method: POST                                 
# Path: /posts
# Auth: Required
# des: will add a post for registered user     
#                                              
###

messages = require "../messages"

module.exports = (request, reply, options) ->
  if request.payload.title isnt '' or request.payload.body isnt ''
    post =
      title: request.payload.title
      body: request.payload.body
      author_email: request.auth.credentials.email
    options.model::setPost post, (err, added) ->
      if err
        throw err
      else if added
        reply messages.post.success
  else
    reply messages.post.isn_payload
