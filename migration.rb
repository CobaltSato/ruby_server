require 'active_record'
ADAPTER = 'sqlite3'
DBFILE  = 'test.sqlite3'

ActiveRecord::Base.establish_connection(adapter: ADAPTER, database: DBFILE)

ActiveRecord::Migration.create_table :users do |t|
  t.string  :name
  t.string  :email
  t.timestamp :created_at, :null => false
end
