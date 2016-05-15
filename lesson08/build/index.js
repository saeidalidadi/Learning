var Hapi, sayhi, server;

Hapi = require("hapi");

server = new Hapi.Server();

server.connection({
  port: 8080,
  host: 'localhost'
});

sayhi = function(name, next) {
  var msg;
  msg = "Hi " + name;
  return next(null, msg);
};

server.method('sayhi', sayhi);

server.route({
  path: '/{name}',
  method: 'GET',
  handler: function(request, reply) {
    return server.methods.sayhi(request.params.name, function(err, result) {
      return reply(result);
    });
  }
});

server.start(function(err) {
  return console.log("Server is running at: " + server.info.uri);
});

