require 'digest/sha1'

module HPFeeds
  class Decoder

    def parse_header(header)
      raise Exception.new("Malformed header") if header.length < 5
  	  len = header[0,4].unpack("l>")[0]
		  op = header[4,1].unpack("C")[0]
      return op, len
    end

    def parse_info(data)
      len = data[0,1].unpack("C")[0]
      raise Exception.new("Malformed data") if data.length <= len
			name = data[1,len]
			rand = data[(1+len)..-1]
      return name, rand
    end

    def parse_publish(data)
			len = data[0,1].unpack("C")[0]
			name = data[1,len]
			len2 = data[(1+len),1].ord
			chan = data[(1+len+1),len2]
			payload = data[(1+len+1+len2)..-1]
      return name, chan, payload
    end

    def msg_auth(rand, ident, secret)
  		mac = Digest::SHA1.digest(rand + secret)
	  	msg_hdr(OP_AUTH, [ident.length].pack("C") + ident + mac)
    end

    def msg_subscribe(ident, chan)
		  msg_hdr(OP_SUBSCRIBE, [ident.length].pack("C") + ident + chan)
	  end

    def msg_publish(ident, chan, msg)
		  msg_hdr(OP_PUBLISH, [ident.length].pack("C") + ident + [chan.length].pack("C") + chan + msg)
	  end

  private

	  def msg_hdr(op, data)
		  [5+data.length].pack("l>") + [op].pack("C") + data
	  end
  end
end
