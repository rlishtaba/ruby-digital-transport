require 'socket'
require 'functional'

module Digital
  module Transport
    module Adapters
      class Tcp
        include Functional
        include Socket::Constants
        include Digital::Transport::Errors
        include Digital::Transport::Adapters::Interface

        DEFAULTS = { timeout: 10 }.freeze

        def initialize(ip, port)
          @ip = ip
          @port = port
          @io = nil
          yield self if block_given?
        end

        # @return [Either] either monad representing a value of one of two possible types
        # 1. Exception covariant
        # 2. Adapter interface invariant
        #
        # @example
        #
        # include Digital::Transport::Adapters
        #
        # on_success = -> x {
        #      puts "connection open? -> #{x.open?}"
        #      x.write("Hello, World!") =>
        #      x.read 2 #=>
        # }
        # on_failure = -> x { puts "Wasn't able to connect due to: #{x.message}" }
        #
        # maybe = new_tcp_adapter('10.0.0.250', 12000).connect
        # maybe.either(on_failure, on_success)
        #
        def connect(opt = { timeout: 10, tcp_no_delay: 1 })
          return open? if open?
          map = opt.dup.freeze
          Socket.new(AF_INET, SOCK_STREAM, 0).tap do |socket|
            socket.setsockopt(IPPROTO_TCP, TCP_NODELAY, map[:tcp_nodelay].to_i)
            return connect_nonblock(
                socket,
                Socket.pack_sockaddr_in(@port, @ip),
                map[:timeout].to_i.nonzero? || DEFAULTS[:timeout])
          end
        end

        # @raise [Errno::ECONNRESET] if connection reset by peer
        #
        # @return [Boolean] representing operation state
        def close
          return !open? unless open?
          flush
          @io && @io.close
          @io = nil
          !open?
        end

        # @raise [Errno::ECONNRESET] if connection reset by peer
        # @return [Ethernet] it self
        def flush
          @io && @io.flush
        end

        # @param [String] string
        # @return [Fixnum] representing amount of bytes written
        def write(string)
          raise NotConnected unless open?
          written = 0
          while 0 < string.bytesize
            begin
              written = @io.write_nonblock(string)
            rescue IO::WaitReadable
              IO.select([@io])
              retry
            rescue IO::WaitWritable
              IO.select(nil, [@io])
              retry
            end
            string = string.byteslice(written..-1)
          end
          Either.right(written)
        rescue => ex
          Either.left(ex)
        end

        # @param [Fixnum] count how many bytes to read
        # @param [Boolean] should_block which will simulate blocking function
        # @return [String, nil] the String which was received or nil otherwise
        def read(count, should_block = false)
          raise NotConnected unless open?
          Either.right @io.read_nonblock(count).tap
        rescue IO::WaitReadable
          if should_block
            IO.select [@io]
            retry
          end
          Either.right(nil)
        rescue => ex
          Either.left(ex)
        end

        # @return [Boolean] connection state predicate
        def open?
          @io && !@io.closed?
        end

        private

        def connect_nonblock(io_like, endpoint, timeout)
          io_like.connect_nonblock(endpoint)
        rescue Errno::EINPROGRESS # connection in progress, wait a bit.
          IO.select(nil, [io_like], nil, timeout) ? retry : nil
        rescue Errno::EISCONN # The socket is already connected.
          @io = io_like
          Either.right(self)
        rescue => ex
          Either.left(ex)
        end
      end
    end
  end
end