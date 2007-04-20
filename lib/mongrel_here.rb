module MongrelHere
    APP_ROOT_DIR    = File.dirname(File.expand_path(File.join(__FILE__,".."))).freeze
    APP_LIB_DIR     = File.join(APP_ROOT_DIR,"lib")
    APP_DATA_DIR    = File.join(APP_ROOT_DIR,"data")

    VERSION         = [0,0,1].freeze
    AUTHOR          = "Jeremy Hinegardner".freeze
    AUTHOR_EMAIL    = "jeremy@hinegardner.org".freeze
    HOMEPAGE        = "http://pieces-of-flare.rubyforge.org/mongrel_here/"
    COPYRIGHT       = "2007 #{AUTHOR}".freeze
    DESCRIPTION     = <<DESC
mongrel_here is a trival webserver to quick and easily serve up the the
web contents of a directory.  
DESC
end

require 'mongrel_here/server'
require 'mongrel_here/dir_handler'
require 'mongrel_here/error_handler'

