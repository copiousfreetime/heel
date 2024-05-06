# frozen_string_literal: true

module Heel
  # Internal: Logger class
  #
  class Logger
    attr_reader :filename

    def initialize(filename)
      @filename = File.expand_path(filename)
    end

    def write(msg)
      File.open(filename, "ab") do |file|
        file.write(msg)
      end
    end
  end
end
