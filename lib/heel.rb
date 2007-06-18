module Heel
    APP_ROOT_DIR    = File.dirname(File.expand_path(File.join(__FILE__,".."))).freeze
    APP_LIB_DIR     = File.join(APP_ROOT_DIR,"lib")
    APP_DATA_DIR    = File.join(APP_ROOT_DIR,"resources")

    VERSION         = [0,0,1].freeze
    AUTHOR          = "Jeremy Hinegardner".freeze
    AUTHOR_EMAIL    = "jeremy@hinegardner.org".freeze
    HOMEPAGE        = "http://copisousfreetime.rubyforge.org/heel/"
    COPYRIGHT       = "2007 #{AUTHOR}".freeze
    DESCRIPTION     = <<DESC
Heel is a trival webserver to quick and easily serve up the the
web contents of a directory.  
DESC
end

require 'rubygems'
require 'mongrel'

require 'heel/server'
require 'heel/dir_handler'
require 'heel/error_handler'

