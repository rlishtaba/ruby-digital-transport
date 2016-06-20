require 'rs_232'

module Digital
  module Transport
    module Adapters
      class Serial
        include Digital::Transport::Errors
        include Digital::Transport::Adapters::Interface
        include CommPort
        include Functional

        DEFAULTS = {
            timeout: 10,
            baud_rate: CommPort::BAUD_115200,
            data_bits: CommPort::DATA_BITS_8,
            parity: CommPort::PAR_NONE,
            stop_bits: CommPort::STOP_BITS_1,
            flow_control: CommPort::FLOW_OFF
        }.freeze

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
          io = Rs232.new(@port)
          io.connecting_timeout = @opts[:timeout].to_i if p.respond_to?(:connecting_timeout)
          io.open
          io.baud_rate = @opts[:baud_rate].to_i
          io.data_bits = @opts[:data_bits].to_i
          io.parity = @opts[:parity].to_i
          io.stop_bits = @opts[:stop_bits].to_i
          io.flow_control = @opts[:flow_control].to_i
          @io = io
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
          @io && !@io.closed?
        end

        def read(count, blocking = false)
          raise NotConnected unless open?
          array = []

          bytes_count = (count == -1) ? @io.available? : count

          if blocking
            bytes = read_io_until(count, count)
            array.push bytes if bytes
          else
            bytes_count.times do
              byte = @io.read(1)
              array.push byte if byte
            end
          end
          Either.right(array.empty? ? nil : array.join)
        rescue => ex
          Either.left(ex)
        end

        private

        # @api private
        #
        # simulate blocking function
        #
        # @param [Fixnum] count
        # @param [Fixnum] up_to
        #
        # no direct ruby usage
        #
        def block_io_until(count, up_to)
          up_to -= 1 while @io.available? < count && up_to > 0
          up_to > 0
        end

        # @api private
        #
        # simulate blocking function
        #
        # @param [Fixnum] count
        # @param [Fixnum] up_to
        #
        # no direct ruby usage
        #
        def read_io_until(count, up_to)
          sleep 0.001 until block_io_until(count, up_to)
          read(count)
        end
      end
    end
  end
end