module Heel
  ROOT_DIR     = File.dirname(File.expand_path(File.join(__FILE__,".."))).freeze
  LIB_DIR      = File.join(ROOT_DIR,"lib")
  DATA_DIR     = File.join(ROOT_DIR,"data")
end

require 'rubygems'
require 'thin'
%w[ version server rackapp directory_indexer request ].each { |l| require "heel/#{l}" }
