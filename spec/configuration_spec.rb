require 'spec/spec_helper'

describe Heel::Configuration do
  it "finds files relative to root of gem" do
    Heel::Configuration.root_dir.should == File.expand_path(File.join(File.dirname(__FILE__), "..")) + "/"
  end

  it "finds files in the config dir of the project" do
    Heel::Configuration.config_path('config.rb').should == File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "config.rb"))
  end
  
  it "finds files in the data dir of the project" do
    Heel::Configuration.data_path('famfamfam', 'icons').should == File.expand_path(File.join(File.dirname(__FILE__), "..", "data", "famfamfam", "icons"))
  end
  
  it "finds files in the lib dir of the project" do
    Heel::Configuration.lib_path('heel.rb').should == File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "heel.rb"))
  end

end
