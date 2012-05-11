require 'drb'
require 'irb'

module Roombox

  class Client
    def Client.new
      DRb.start_service
      DRbObject.new(nil, 'druby://localhost:9900')
    end
  end
end

$player = Roombox::Client.new

IRB.start
