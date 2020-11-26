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

  def getParams(regex, session)
    content_length = Helper.content_length(session)
    return nil if content_length == nil
    session.read(content_length).scan(regex).flatten
  end

  module_function :content_length, :getParams
end
