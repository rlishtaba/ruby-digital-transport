require 'rs_232'
require 'timeout'

module Digital
  module Transport
    module Adapters
      class Serial
        include Digital::Transport::Errors
        include Digital::Transport::Adapters::Interface
        include Functional
        include Rs232

        DEFAULTS = { timeout: 10 }.freeze

        def initialize(port, opt = {})
          @port = port.freeze
          @opts = DEFAULTS.merge(opt.dup).freeze
          @io = nil
        end

        # @return [Either] monad representing a value of one of two possible types
        # 1. Exception covariant
        # 2. Adapter interface invariant
        #
        # @see Adapters#new_serial_adapter
        #
        def connect
          @io = new_serial_port(@port, @opts).tap(&:connect)
          Either.right(self)
        rescue Exception => ex
          Either.left(ex)
        end

        def write(bytes)
          raise NotConnected unless open?
          Either.right(@io.write(bytes))
        rescue => ex
          Either.left(ex)
        end

        def close
          return !open? unless open?
          @io && @io.close
          @io = nil
          !open?
        end

        def flush
          @io && @io.flush
        end

        def open?
          @io && @io.open?
        end

        def read(count, blocking = false)
          raise NotConnected unless open?
          f = blocking ? method(:read_blocking) : method(:read_non_blocking)
          Either.right f.(count)
        rescue => ex
          @io.close
          Either.left(ex)
        end

        private

        def read_non_blocking(count)
          @io.read(count)
        end

        # todo: shouldn't block forever.
        def read_blocking(count)
          bytes = ''
          while bytes.length < count
            bytes += read_non_blocking(count).to_s
            sleep 0.001
          end
          bytes
        end
      end
    end
  end
end
