puffer  = require "puffer"
elastic = require "elasticsearch"
config  = require "./config"

exports.db = new puffer { port: config.database.port, host: config.database.host, name: 'default' }

exports.searchEng = new elastic.Client({
  host: "localhost:#{config.elastic.port}"
  #log: 'trace'
})


