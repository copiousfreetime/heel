begin
    require 'rubygems'
    require 'heel'
    require 'spec'
    require 'net/http'
rescue LoadError
    $: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
    require 'heel'
end