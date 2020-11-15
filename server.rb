require "socket"
require "erb"
require "uri"

port = 48002
server = TCPServer.open(port)

class User
  def initialize(fname)
    @fname = fname
  end

  # 新規ユーザをcsvに書き込む
  def create(fields)
    f = File.open(@fname, "a")
    f.write("#{fields[:name]}, #{fields[:email]}\n")
    f.close
  end

  # すべてのユーザデータを"user,email"の配列で返す
  def all()
    f = File.open(@fname, "r")
    users = f.read.split(/\R/)
    f.close
    return users
  end
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
$user = User.new("users.csv")
$name = "noname"
$email = "nobody@invalid.com"
while true
  Thread.start(server.accept) do |socket|
    request = socket.gets
    p request

    method = request.split(' ')[0]
    url = request.split(' ')[1]

    if method.eql?("GET")
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

        if $name != params[1] && $email != params[3]
          $name = params[1]
          $email = params[3]
          $user.create(name: $name, email: URI.decode($email))
          puts "Input name: $name, email: $email"

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
        end
      end
    end

    socket.close
  end
end

server.close

