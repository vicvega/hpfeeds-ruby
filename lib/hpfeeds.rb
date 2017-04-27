require 'hpfeeds/version'
require 'timeout'

module HPFeeds
  autoload :Client, 'hpfeeds/client'
  autoload :Decoder, 'hpfeeds/decoder'
  # exceptions
  autoload :Exception, 'hpfeeds/exception'
  autoload :ErrorMessage, 'hpfeeds/exception'
end
