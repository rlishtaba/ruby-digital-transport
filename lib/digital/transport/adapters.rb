require 'functional'

module Digital
  module Transport
    # @example
    #
    # require 'digital/transport'
    #
    # include Digital::Transport::Adapters
    #
    # @see Proc#new
    # connected = -> x {
    #      x.write("Hello, World!") #=> either monad
    #      x.read 2                 #=> either monad
    # }
    #
    # @see Proc#new
    # failed = -> x {
    #      # perform exceptional situation handling
    #      # x will be yielded in to function as an Exception covariant interface.
    #      puts "Wasn't able to connect due to: #{x.message}. Handling failure."
    # }
    #
    # @see Tcp#connect
    # maybe = new_tcp_adapter('10.0.0.250', 12000).connect
    #
    # @see Either#either
    # maybe.either(failed, connected)
    #
    module Adapters
      require 'digital/transport/adapters/interface'
      autoload :Tcp, 'digital/transport/adapters/tcp'
      autoload :Serial, 'digital/transport/adapters/serial'

      private_constant :Tcp, :Serial

      def new_tcp_adapter(ip, port)
        Tcp.new(ip.dup.freeze, port)
      end

      def new_serial_adapter(_port, _opts = {})
        raise NotImplementedError
      end

      def new_usb_adapter(_port, _opts = {})
        raise NotImplementedError
      end
    end
  end
end
