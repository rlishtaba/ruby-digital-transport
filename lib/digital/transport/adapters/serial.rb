require 'rs_232'

module Digital
  module Transport
    module Adapters
      class Serial
        include Digital::Transport::Errors
        include Digital::Transport::Adapters::Interface
        include Functional

      end
    end
  end
end