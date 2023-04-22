require "http"
require "json"
require "uri"
require "http"

module Zippy
  VERSION = "0.1.0"

  class App
    def initialize
      puts "El servidor esta Iniciando..."
      @routes = Hash(String, Hash(String, Proc(HTTP::Server::Context, Nil))).new
    end

    def route(method, path, &block : HTTP::Server::Context -> Nil)
      @routes[method] ||= {} of String => Proc(HTTP::Server::Context, Nil)
      @routes[method][path] = block
    end

    def get(path, &block : HTTP::Server::Context -> Nil)
      route("GET", path, &block)
    end


    def handle_request(context, &block : HTTP::Server::Context, JSON::Any | HTTP::FormData::Part -> Nil)
      request = context.request
      content_type = request.headers["Content-Type"]
    
      if content_type.starts_with?("application/json")
        json = JSON.parse(request.body.not_nil!.gets_to_end)
        block.call(context, json)
      elsif content_type.starts_with?("multipart/form-data")
        HTTP::FormData.parse(request) do |part|
          block.call(context, part)
        end
      else
        context.response.status_code = 400
        context.response.print "Tipo de contenido no soportado"
      end
    end
    
    def post(path, &block : HTTP::Server::Context, JSON::Any | HTTP::FormData::Part -> Nil)
      route("POST", path) do |context|
        handle_request(context, &block)
      end
    end
    
    def put(path, &block : HTTP::Server::Context, JSON::Any | HTTP::FormData::Part -> Nil)
      route("PUT", path) do |context|
        handle_request(context, &block)
      end
    end
    
    

    def delete(path, &block : HTTP::Server::Context -> Nil)
      route("DELETE", path, &block)
    end

    def run(host = "localhost", port = 3000)
      
      server = HTTP::Server.new do |context|
        method = context.request.method
        path = context.request.path
        handler = @routes[method]?.try &.[](path)

        if handler
          handler.call(context)
        else
          context.response.status_code = 404
          context.response.print "Not found"
        end
      end

      puts "Servidor iniciado en http://#{host}:#{port}/"
      server.bind_tcp(host, port)
      server.listen
      
    end
  end
end
