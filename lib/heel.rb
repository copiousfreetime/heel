module Heel
    APP_ROOT_DIR     = File.dirname(File.expand_path(File.join(__FILE__,".."))).freeze
    APP_LIB_DIR      = File.join(APP_ROOT_DIR,"lib")
    APP_DATA_DIR     = File.join(APP_ROOT_DIR,"data")
end

require 'rubygems'
require 'mongrel'

require 'heel/version'
require 'heel/specification'
require 'heel/gemspec'
require 'heel/server'
require 'heel/dir_handler'
require 'heel/error_handler'

