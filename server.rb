require "socket"
require "erb"
require "uri"
require 'active_record'
require './helper'
ADAPTER = 'sqlite3'
DBFILE  = 'test.sqlite3'

ActiveRecord::Base.establish_connection(adapter: ADAPTER, database: DBFILE)

class User < ActiveRecord::Base
end

class UsersController
  attr_reader :rendered
  def index
    render "./views/index.html.erb"
  end

  def show(_id)
    @id = _id
    render "./views/show.html.erb"
  end

  def create(params)
    if User.create(name: params[0], email: URI.decode(params[1]), hobby: params[2])
      render "./views/onclick.html"
    else
      render "./views/index.html.erb"
    end
  end

  private
  def render(fname)
    @rendered = nil if !fname
    File.open(fname) { |f|
      @rendered = ERB.new(f.read).result(binding)
    }
  end

end

class Service
  def initialize(session)
    @usersController = UsersController.new
    @session = session
    @method, @url = session.gets.split(' ')
  end

  def rendered
    @usersController.rendered
  end

  def routes()
    if @url.eql?('/') && @method.eql?("GET")
      @usersController.index
    end

    if @url.match(/\/users\/?$/) && @method.eql?("GET")
      @usersController.index
    end

    if @url.match(/\/users\/\d+\/?$/) && @method.eql?("GET")
      id = @url.scan(/\/users\/(\d*)\/?$/).flatten.first.to_i
      @usersController.show(id)
    end

    if @url.match(/\/users\/?$/) && @method.eql?("POST")
      params = Helper.getParams(/name=(.*)&email=(.*)&hobby=(.*)/, @session)
      @usersController.create(params)
    end
  end

end

port = 48002
server = TCPServer.open(port)
while true
  Thread.start(server.accept) do |session|
    service = Service.new(session)

    service.routes()

    session.write <<-EOF
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Server: rserver
Connection: close

#{service.rendered}
  EOF

    session.close
  end
end
server.close
