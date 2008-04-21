#--
# Copyright (c) 2007, 2008 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license.  See LICENSE for details
#++

require 'heel'
require 'rack'

module Heel

  # wrapper around the rack common logger to open up the file and flush the logs
  # this is invoked with a 'use' command in the Builder so a new instance of
  # 'Logger' in created with each request, so we do all the heavy lifting in the
  # meta class.
  #
  class Logger < ::Rack::CommonLogger
    class << self
      def log
        # the log can get closed if daemonized, the at_exit will close it.
        if @log.closed? then
          @log = File.open(@log_file, "a")
        end
        @log
      end

      def log_file=(lf)
        @log_file = lf
        @log = File.open(@log_file, "a")
        at_exit { @log.close unless @log.closed? }
      end
    end

    def initialize(app)
      super(app)
    end

    def <<(str)
      Heel::Logger.log.write( str )
      Heel::Logger.log.flush
    end
  end
end
