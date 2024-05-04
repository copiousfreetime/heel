module Heel
  # Internal: Logger class
  #
  class Logger
    attr_reader :filename
    def initialize( filename )
      @filename = File.expand_path( filename )
    end

    def write( msg )
      File.open( filename, "ab" ) do |f|
        f.write( msg )
      end
    end
  end
end
