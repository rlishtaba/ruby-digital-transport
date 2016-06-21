require 'socket'
require 'timeout'
require 'functional'

module Digital
  module Transport
    module Adapters
      class Tcp
        include Functional
        include Socket::Constants
        include Digital::Transport::Errors
        include Digital::Transport::Adapters::Interface

        DEFAULTS = { timeout: 10, tcp_no_delay: 1 }.freeze

        def initialize(ip, port, opts = {})
          @ip = ip.freeze
          @opts = DEFAULTS.merge(opts.dup).freeze
          @port = port
          @io = nil
        end

        # @return [Either] monad representing a value of one of two possible types
        # 1. Exception covariant
        # 2. Adapter interface invariant
        #
        # @see Adapters#new_tcp_adapter
        #
        def connect
          return open? if open?
          Socket.new(AF_INET, SOCK_STREAM, 0).tap do |socket|
            socket.setsockopt(IPPROTO_TCP, TCP_NODELAY, (@opts[:tcp_nodelay] || DEFAULTS[:tcp_no_delay]).to_i)
            return connect_nonblock(
                socket,
                Socket.pack_sockaddr_in(@port, @ip),
                @opts[:timeout].to_i.nonzero? || DEFAULTS[:timeout]
            )
          end
        end

        # @return [Boolean] representing operation state
        def close
          return !open? unless open?
          flush
          @io && @io.close
          @io = nil
          !open?
        end

        def flush
          @io && @io.flush
        end

        # @param [String] string
        def write(string)
          raise NotConnected unless open?
          written = 0
          while 0 < string.bytesize
            begin
              written = @io.write_nonblock(string)
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
        def read(count, should_block = false)
          raise NotConnected unless open?
          Either.right @io.read_nonblock(count)
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

        # @api private
        def connect_nonblock(io_like, endpoint, timeout)
          io_like.connect_nonblock(endpoint)
          raise Errno::EISCONN
        rescue Errno::EINPROGRESS
          if IO.select(nil, [io_like], nil, timeout)
            retry
          else
            io_like.close
            Either.left(Timeout::Error.new('Connection timeout'))
          end
        rescue Errno::EISCONN
          init_io io_like
          Either.right(self)
        rescue => ex
          io_like.close
          Either.left(ex)
        end
        
        def init_io(io)
          @io = io
        end
      end
    end
  end
end
