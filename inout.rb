#! /usr/bin/ruby

class User
  def initialize(csvFileObj)
    @csvFileObj =  csvFileObj
  end

  def writeUserRecordToCSV(name, email)
    @csvFileObj.write("#{name}, #{email}\n")
  end
end

# _main

# Init
csvFileObj = File.open('users.csv', "a")
file = User.new(csvFileObj) 
qmark = "?"
$name = "noname"
$email = "nobody@invalid.com"

# Input
"$name,$email".split(',').each do |field|
  eval "puts(field + qmark)"
  STDOUT.flush
  eval "#{field} = gets.to_s.chomp"
end

# Output  
file.writeUserRecordToCSV($name, $email)
 
# End
csvFileObj.close
