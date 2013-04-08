require 'hpfeeds/version'

module HPFeeds
  autoload :Client, 'hpfeeds/client'
  autoload :Decoder, 'hpfeeds/decoder'
  # exceptions
  autoload :Exception, 'hpfeeds/exception'
  autoload :ErrorMessage, 'hpfeeds/exception'
end
