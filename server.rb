require "socket"
require "erb"
require "uri"
require 'active_record'
ADAPTER = 'sqlite3'
DBFILE  = 'test.sqlite3'

port = 48002
server = TCPServer.open(port)

ActiveRecord::Base.establish_connection(adapter: ADAPTER, database: DBFILE)

class User < ActiveRecord::Base

end

class UsersController
  def index
    fname = "./views/index.html.erb"
    return content(fname)
  end
  def show
    fname = "./views/show.html.erb"
    return content(fname)
  end
  private
  def content(fname)
    f = File.open(fname)
    content = ERB.new(f.read).result(binding)
    f.close
    return content
  end
end

def routes(method, url, socket)
  if method.eql?("GET")
    if url.eql?('/users') || url.eql?('/')
      return $usersController.index
    end
    if url.include?('/users/')
      $id = url['/users/'.length].to_i
      return $usersController.show
    end
  end # if method.eql?("GET")

  if method.eql?("POST") && url.eql?('/users')
    # content_lengthを取り出す
    while req_header = socket.gets.chomp
      break if req_header == ''
      h = req_header.split(':')
      if h[0].strip.downcase == 'content-length'
        content_length = h[1].strip.to_i
      end
    end

    # bodyを読み込む
    if content_length != nil
      params = socket.read(content_length).to_s.split(/=|&/)

      if $name != params[1] && $email != params[3] && $hobby != params[5]
        $name = params[1]
        $email = params[3]
        $hobby = params[5]
        # $user.create(name: $name, email: URI.decode($email))
        user = User.new
        user.name  = $name
        user.email = URI.decode($email)
        user.hobby = $hobby
        user.save
        puts "Input name: $name, email: $email"

        # ありがとうございました.と表示する:
        f = File.open("./views/onclick.html")
        content = ERB.new(f.read).result(binding)
        f.close
        return content
      end # if $name != params[1] && $email != params[3] && $hobby != params[5]
    end # if content_length != nil
  end # if method.eql?("POST")
end

$id = 0
$name = "noname"
$email = "nobody@invalid.com"
$hobby = "nothing"
$usersController = UsersController.new

while true
  Thread.start(server.accept) do |socket|
    request = socket.gets
    method = request.split(' ')[0]
    url = request.split(' ')[1]
    puts method, url

    content = routes(method, url.to_s, socket)
    socket.write <<-EOF
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Server: rserver
Connection: close

#{content}
EOF
    socket.close
  end
end

server.close
