require 'functional'

module Digital
  module Transport
    module Adapters
      module Interface
        def open?
          not_implemented __method__
        end

        def write(_message)
          not_implemented __method__
        end

        def read(_bytes, _should_block = false)
          not_implemented __method__
        end

        def close
          not_implemented __method__
        end

        def connect
          not_implemented __method__
        end

        private

        def not_implemented(message)
          Functional::Either.left(NotImplementedError.new(message))
        end
      end
    end
  end
end
