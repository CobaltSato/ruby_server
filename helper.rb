module Helper
  def content_length(socket)
    while req_header = socket.gets.chomp
      break if req_header == ''
      h = req_header.split(':')
      if h[0].strip.downcase == 'content-length'
        content_length = h[1].strip.to_i
      end
    end
    return content_length
  end

  def getParams(keys, session)
    return nil if keys.length == 0
    pattern = ""
    keys.each do |pName|
      pattern << "#{pName}=(.*)&"
    end 
    regex = Regexp.new(pattern.chop)
    line = Helper.content_length(session)
    values = session.read(line).scan(regex).flatten
    keys.zip(values).to_h
  end

  module_function :content_length, :getParams
end
