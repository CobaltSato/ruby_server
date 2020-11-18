require "socket"
require "erb"
require "uri"
require 'active_record'
require './helper'
ADAPTER = 'sqlite3'
DBFILE  = 'test.sqlite3'

port = 48002
server = TCPServer.open(port)

ActiveRecord::Base.establish_connection(adapter: ADAPTER, database: DBFILE)

class User < ActiveRecord::Base

end

# urlへpostしたときの処理
def post(url, socket)
  if url.eql?('/users')
    content_length = Helper.content_length(socket)
    return "" if content_length == nil

    # name, email, hobbyを取り出す
    params = socket.read(content_length).to_s.split(/=|&/)
    name = params[1]
    email = params[3]
    hobby = params[5]

    # user作成
    user = User.new(name: name, email: URI.decode(email), hobby: hobby)
    user.save
    puts "saved: \n   name: #{name}, email: #{email}, hobby: #{hobby}"

    # ありがとうございました と表示する:
    ret = ""
    File.open("./views/onclick.html") { |f|
      ret = ERB.new(f.read).result(binding)
    }
    return ret
  end
end

# urlへgetしたときの処理
def get(url)
  if url.eql?('/users') || url.eql?('/')
    return Render.new.index
  end
  if url.include?('/users/')
    id = url['/users/'.length].to_i
    return Render.new.show(id)
  end
end

class Render
  # indexページのレンダリング
  def index
    fname = "./views/index.html.erb"
    return content(fname)
  end

  # showページのレンダリング
  def show(_id)
    fname = "./views/show.html.erb"
    @id = _id
    return content(fname)
  end

  private
  # 変換: erbファイル名 -> htmlファイルへ
  def content(fname)
    ret = ""
    File.open(fname) { |f|
      ret = ERB.new(f.read).result(binding)
    }
    return ret
  end
end

def routes(method, url, socket)
  if method.eql?("GET")
    return get(url)
  end

  if method.eql?("POST")
    return post(url, socket)
  end
end

# main
while true
  Thread.start(server.accept) do |socket|
    # method, urlを調べる
    request = socket.gets
    method = request.split(' ')[0]
    url = request.split(' ')[1]
    puts method, url

    # method, urlに応じて処理
    content = routes(method, url.to_s, socket)

    # html形式で返す
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
# _main end
