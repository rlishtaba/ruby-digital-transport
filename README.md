[![Build Status](https://travis-ci.org/rlishtaba/digital-transport.svg?branch=master)](https://travis-ci.org/rlishtaba/digital-transport)

# Digital::Transport

Unified interface to TCP, Serial & USB communication adapters.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'digital-transport'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install digital-transport

## Usage

    require 'digital/transport'
    
    include Digital::Transport::Adapters
    
    connected = -> x {
         x.write("Hello, World!") #=> either monad
         x.read 2                 #=> either monad
    }
    
    failed = -> x {
         # perform exceptional situation handling
         # x will be yielded in to function as an Exception covariant interface.
         puts "Wasn't able to connect due to: #{x.message}. Handling failure."
    }
    
    maybe = new_tcp_adapter('10.0.0.250', 6789).connect
    
    maybe.either(failed, connected)
    

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/digital-transport. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

