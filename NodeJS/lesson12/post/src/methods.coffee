model = require "./model"

module.exports = (server, options) ->
  methods =
    countPagination: (userEmail, next) ->
      options.model::countPosts userEmail, (total) ->
        if total % 5 is 0 and total >= 5
          paginations = total // 5
        else if total > 5
          paginations = (total // 5) + 1
        next(null, paginations)
    randomPosts: (amount, excluds, next) ->
      
  methodsList = [
    {
      name: 'countPagination'
      method: methods.countPagination
      options: {}
    }
    {
      name: 'randomPosts'
      method: methods.randomPosts
      options: {}
    }
  ]

  for method in methodsList
    server.method( method.name, method.method, method.options)




