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

# postしたとき, session内容とurlに応じて処理を実行, レンダリング結果を返す
def post(url, session)
  if url.match(/\/users\/?$/)
    # name, email, hobbyを取り出す
    content_length = Helper.content_length(session)
    return "" if content_length == nil
    params = session.read(content_length).scan(/name=(.*)&email=(.*)&hobby=(.*)/).flatten

    # user作成
    user = User.new(name: params[0], email: URI.decode(params[1]), hobby: params[2])
    puts "name: #{params[0]}, email: #{params[1]}, hobby: #{params[2]}"
    return "" if !user.save

    # ありがとうございました と表示する:
    ret = ""
    File.open("./views/onclick.html") { |f|
      ret = ERB.new(f.read).result(binding)
    }
    return ret
  end
end

# getしたとき, urlに応じてレンダリング結果を返す
def get(url)
  cl = UsersController.new
  if url.match(/\/users\/?$/) || url.eql?('/') # '/users/', '/users', ('/')
    return cl.index
  end
  if url.match(/\/users\/\d*\/?$/)
    id = url.scan(/\/users\/(\d*)\/?$/).flatten.first.to_i
    return cl.show(id)
  end
end

# {index, show.. }のページのレンダリングを担当
class UsersController
  # indexページのレンダリング結果を返す
  def index
    fname = "./views/index.html.erb"
    return content(fname)
  end

  # showページのレンダリング結果を返す
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

# methodに応じて, get/postを呼び出し, そのレンダリング結果を返す
def routes(method, url, session)
  if method.eql?("GET")
    return get(url)
  end
  if method.eql?("POST")
    return post(url, session)
  end
end

# main
while true
  Thread.start(server.accept) do |session|
    # method, urlを取り出す
    request = session.gets
    method, url = request.split(' ')
    puts "method: #{method}, url: #{url}"

    # method, urlに応じて処理し, レンダリング結果を取得
    content = routes(method, url.to_s, session)

    # レンダリング結果をメッセージに含める
    session.write <<-EOF
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Server: rserver
Connection: close

#{content}
EOF
    session.close
  end
end
server.close
