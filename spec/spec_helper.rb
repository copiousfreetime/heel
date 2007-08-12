begin
    require 'heel'
    require 'rspec'
rescue LoadError
    $: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
    require 'heel'
end