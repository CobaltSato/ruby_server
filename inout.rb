#! /usr/bin/ruby

# ユーザのデータを記録するcsvファイルを扱うためのクラス
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

  # すべてのユーザデータをcsv形式で返す
  def all()
    f = File.open(@fname, "r")
    contents = f.read
    f.close
    return contents
  end
end

# 名前とemailを受け付けて, csvに書き込む
def create
  qmark = "?"
  name = "noname"
  email = "nobody@invalid.com"
  "name,email".split(',').each do |field|
    eval "puts(field + qmark)"
    STDOUT.flush
    eval "#{field} = gets.to_s.chomp"
  end
  $user.create(name: name, email: email)
end

# すべてのユーザを表示する
def index
  puts $user.all()
end

# _main
$user = User.new("users.csv")
while true
  # コマンド名を受け付ける:
  puts "Please input create, index, or exit"
  STDOUT.flush
  command = gets.to_s.chomp

  # コマンドを実行する:
  if command.eql?("create")
    create
  elsif command.eql?("index")
    index
  elsif command.eql?("exit")
    break
  else
    puts "[ERROR] no such a command"
  end
end
