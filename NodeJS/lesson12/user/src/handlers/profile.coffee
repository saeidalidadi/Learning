module.exports = (request, reply, options) ->
  email = request.auth.credentials.email
  options.model.getUser email, (err, user) ->
    locals =
      name: user.name
      email: user.email
    reply.view "profile", locals


