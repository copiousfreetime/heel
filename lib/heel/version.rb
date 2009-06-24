#--
# Copyright (c) 2007, 2008 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license.  See LICENSE for details
#++

module Heel
  module Version
    MAJOR   = 1 
    MINOR   = 0 
    BUILD   = 4

    def to_a
      [MAJOR, MINOR, BUILD]
    end

    def to_s
      to_a.join(".")
    end
    module_function :to_a
    module_function :to_s

    STRING = Version.to_s
  end 
  VERSION = Version.to_s
end

