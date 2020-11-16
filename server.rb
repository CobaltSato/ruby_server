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

def routes(url)
  if url.eql?('/users') || url.eql?('/')
    return "index.html.erb"
  end
  if url.include?('/users/')
    $id = url['/users/'.length].to_i
    return "show.html.erb"
  end
end

$id = 0
$name = "noname"
$email = "nobody@invalid.com"
$hobby = "nothing"
while true
  Thread.start(server.accept) do |socket|
    request = socket.gets
    method = request.split(' ')[0]
    url = request.split(' ')[1]
    puts method, url

    if method.eql?("GET")
      # 対応するviewを表示する
      fname = routes(url.to_s)
      if !fname.nil?
        f = File.open(fname)
        content = ERB.new(f.read).result(binding)
        f.close
      end
      socket.write <<-EOF
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Server: rserver
Connection: close

#{content}
      EOF
    end

    if method.eql?("POST")
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
          f = File.open("onclick.html")
          content = ERB.new(f.read).result(binding)
          f.close
          socket.write <<-EOF
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Server: rserver
Connection: close

#{content}
      EOF
        end # if $name != params[1] && $email != params[3] && $hobby != params[5]
      end # if content_length != nil
    end # if method.eql?("POST")

    socket.close
  end
end

server.close
