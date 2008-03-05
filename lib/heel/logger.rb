#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license.  See LICENSE for details
#++

require 'heel'
require 'rack'

module Heel

  # wrapper around the rack common logger to open up the file and flush the logs
  #
  class Logger < ::Rack::CommonLogger

    def initialize(app, log_file)
      @logfile = File.open(log_file, "a")
      super(app)
      at_exit { @logfile.close }
    end

    def <<(str)
      @logfile.write( str )
      @logfile.flush
    end
  end
end
