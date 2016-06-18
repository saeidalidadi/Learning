module.exports = (server, options) ->
  
  [{
    path: '/'
    method: 'GET'
    config:
      auth: { mode: 'try' }
    handler: (request, reply) ->
      require("./handlers/home") request, reply, options
  }
  ,
  {
    path: '/me/posts'
    method: 'GET'
    handler: (request, reply) ->
      require("./handlers/user-posts") request, reply, options
  }
  ,
  {
    path: '/posts'
    method: ['GET','POST']
    config:
      auth: mode: 'try'
    handler: (request, reply) ->
      if request.method is 'get'
        require("./handlers/posts-page") request, reply, options
      else require("./handlers/posts") request, reply, options
  }
  ,
  {
    path: '/update/{doc_key}'
    method: 'GET'
    handler: (request, reply) ->
      require("./handlers/update-page") request, reply, options
  }
  ,
  {
    path: '/posts/{post_key}'
    method: ['PUT', 'DELETE', 'GET']
    config:
      auth: mode: 'try'
    handler: (request, reply) ->
      if request.method is 'put'
        require("./handlers/update-post") request, reply, options
      else if request.method is 'delete'
        require("./handlers/delete-post") request, reply, options
      else if request.method is 'get'
        require("./handlers/one-post") request, reply, options
  }]

