###
#
# logout.coffee
# Method: 'POST' 
# Path: '/logout'
#
###

messages = require '../messages'

module.exports =  (request, reply) ->
  if request.auth.isAuthenticated
    id = request.auth.credentials.id
    delete request.server.app.logins[id]
    reply messages.logout.success
  else
    reply messages.logout.isn_loggedin

