require 'eventmachine'
require 'lib/api'
module Server
  module_function

  def run
    EM.run do
      EM.start_server '0.0.0.0', '8080', Api
      puts 'em was started'
    end
  end
end
