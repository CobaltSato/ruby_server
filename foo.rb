require 'active_record'
# Userモデル
class User < ActiveRecord::Base

end

# User操作user = User.new
user = User.new
user.name  = "testuser"
user.email = "test@example.com"
user.save
User.all.count  #=> 1
user = User.all.first
user.destroy
User.all.count  #=> 0
