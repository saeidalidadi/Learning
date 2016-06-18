###
#
# main.coffee
# Plugin: post
#
###

module.exports = (server, options, next) ->
  # adding post model
  options.model = require("./model") options
  server.handler('posts', require "./handlers/posts")
  
  # adding server methods
  require("./methods") server, options
  
  # adding routes
  server.route require("./routes") server, options
  next()
