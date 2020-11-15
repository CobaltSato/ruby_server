require 'active_record'
ADAPTER = 'sqlite3'
DBFILE  = 'test.sqlite3'

# DB接続
ActiveRecord::Base.establish_connection(adapter: ADAPTER, database: DBFILE)



# Userモデル
class User < ActiveRecord::Base; end

# User操作
user = User.new
user.name  = "testuser"
user.email = "test@example.com"
user.save
User.all.count  #=> 1
p user = User.all.first
user.destroy
User.all.count  #=> 0
