require 'heel'

module Heel
    class Version
        MAJOR   = 0 
        MINOR   = 1 
        TINY    = 0 

        class << self
            def to_a
                [MAJOR, MINOR, TINY]
            end

            def to_s
                to_a.join(".")
            end
        end
    end 
    VERSION = Version.to_s
end

