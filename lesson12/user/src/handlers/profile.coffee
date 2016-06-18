module.exports = (request, reply) ->
  email = request.auth.credentials.email
  model.getUser email, (err, user) ->
    locals =
      name: user.name
      email: user.email
    reply.view "profile", locals


