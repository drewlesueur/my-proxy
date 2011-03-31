http = require "http"
util = require "util"
url = require "url"
path = require "path"
fs = require "fs"
sys = require "sys"
mime = require "mime"

httpProxy = require "http-proxy"
config = require("./config")
routes = config.routes
homeDir = config.homeDir

console.log routes

proxy = new httpProxy.HttpProxy()


getHostName = (req) ->
  host = req.headers["host"]
  if host.indexOf(":") != -1
    host = host.split(":")[0]
  host

handle404 = (filename, res) ->
  #TODO: first try the sites 404
  res.write("404. File (#{filename}) not found <a
  href=\"http://twitter.com/drewlesueur\">@drewlesueur</a>");  
  res.end()

handle500 = (filename, res) ->
  res.writeHead(500, {"Content-Type": "text/html"});  
  res.write("500. File (#{filename}) error <a
  href=\"http://twitter.com/drewlesueur\">@drewlesueur</a>");  
  res.end()
  
handleFile = (filename, res) ->
  mimeType = mime.lookup filename
  fs.readFile filename, (err, data) ->
    if err
      handle500 filename, res
    res.writeHead 200, "Content-Type" : mimeType
    if not data then data = ""
    res.write data, "binary"
    res.end()



   

server = http.createServer (req, res) ->
  host = getHostName req
  if host of routes
    newPort = routes[host]
    proxy.proxyRequest req, res, newPort, '127.0.0.1'
  else
    #http://net.tutsplus.com/tutorials/javascript-ajax/learning-serverside-javascript-with-node-js/
    uri = url.parse(req.url).pathname
   
    if uri is "/" then uri = "/index.html"
    filename = homeDir + host + uri

    path.exists filename, (exists) ->
      if not exists
        handle404 filename, res
      else
        handleFile filename, res

server.listen 80


