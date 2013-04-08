require 'logger'
require 'socket'

module HPFeeds
  OP_ERROR     = 0
  OP_INFO      = 1
  OP_AUTH      = 2
  OP_PUBLISH   = 3
  OP_SUBSCRIBE = 4

  BUFSIZE    = 16384
  HEADERSIZE = 5

  class Client
    def initialize(options)
      @host   = options[:host]
      @port   = options[:port] || 10000
      @ident  = options[:ident]
      @secret = options[:secret]

      @timeout   = options[:timeout]   || 3
      @reconnect = options[:reconnect] || true
      @sleepwait = options[:sleepwait] || 20

      @connected = false
      @stopped   = false

      @decoder      = Decoder.new
      @logger       = Logger.new($stdout)
      @logger.level = Logger::INFO

      @handlers = {}

      tryconnect
    end

    def tryconnect
      loop do
        begin
          connect()
          break
        rescue => e
          @logger.warn("#{e.class} caugthed while connecting: #{e}. Reconnecting in #{@sleepwait} seconds...")
          sleep(@sleepwait)
        end
      end
    end

    def connect
      @socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
      begin
        @logger.debug("connecting #{@host}:#{@port}")
        sockaddr = Socket.pack_sockaddr_in( @port, @host )
        @socket.connect(sockaddr)
      rescue => e
        raise Exception.new("Could not connect to broker: #{e}.")
      end
      @logger.debug("waiting for data")
      header = recv_timeout(HEADERSIZE)
      opcode, len = @decoder.parse_header(header)
      @logger.debug("received header, opcode = #{opcode}, len = #{len}")

      if opcode == OP_INFO
        data = recv_timeout(len)
        @logger.debug("received data = #{data}")
        name, rand = @decoder.parse_info(data)
        @logger.debug("received INFO, name = #{name}, rand = #{rand}")
        @brokername = name
        auth = @decoder.msg_auth(rand, @ident, @secret)
        @socket.send(auth, 0)
      else
        raise Exception('Expected info message at this point.')
      end
      @logger.info("connected to #{@host}, port #{@port}")
      @connected = true
      # set keepalive
      @socket.setsockopt(Socket::Option.bool(:INET, :SOCKET, :KEEPALIVE, true))
    end

    def subscribe(*channels, &block)
      if block_given?
        handler = block
      end
      for c in channels
        @logger.info("subscribing to #{c}")
        message = @decoder.msg_subscribe(@ident, c)
        @socket.send(message, 0)
        @handlers[c] = handler unless handler.nil?
      end

    end

    def publish(data, *channels)
      for c in channels
        @logger.info("publish to #{c}: #{data}")
        message = @decoder.msg_publish(@ident, c, data)
        @socket.send(message, 0)
      end
    end

    def stop
      @stopped = true
    end

    def close
      begin
        @logger.debug("Closing socket")
        @socket.close
      rescue => e
        @logger.warn("Socket exception when closing: #{e}")
      end
    end

    def run(message_callback, error_callback)
      begin
        while !@stopped
          while @connected
            header = @socket.recv(HEADERSIZE)
            if header.empty?
              @connected = false
              break
            end
            opcode, len = @decoder.parse_header(header)
            @logger.debug("received header, opcode = #{opcode}, len = #{len}")
            data = @socket.recv(len)
            @logger.debug("received #{data.length} bytes of data")
            if opcode == OP_ERROR
              error_callback.call(data)
            elsif opcode == OP_PUBLISH
              name, chan, payload = @decoder.parse_publish(data)
              @logger.info("received #{payload.length} bytes of data from #{name} on channel #{chan}")
              handler = @handlers[chan]
              if handler.nil?
                message_callback.call(name, chan, payload)
              else
                handler.call(name, chan, payload)
              end
            end
          end
          @logger.debug("Lost connection, trying to connect again...")
          tryconnect
        end

      rescue => e
        message = "#{e.class} caugthed in main loop: #{e}\n"
        message += e.backtrace.join("\n")
        @logger.error(message)
      end
    end

  private
    def recv_timeout(len=BUFSIZE)
      if IO.select([@socket], nil, nil, @timeout)
        @socket.recv(len)
      else
        raise Exception.new("Connection receive timeout.")
      end
    end

  end
end
