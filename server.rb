require "socket"
require "erb"

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
while true
  Thread.start(server.accept) do |socket|
    p socket.peeraddr

    request = socket.gets
    p request

    method = request.split(' ')[0]
    url = request.split(' ')[1]
    p url

    if method.eql?("GET")
      user = User.new("users.csv")
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

    socket.close
  end
end

server.close

