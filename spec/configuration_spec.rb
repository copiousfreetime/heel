require 'spec_helper'
require 'pathname'

describe Heel::Configuration do
  before do
    @proj_root = Pathname.new( __FILE__ ).parent.parent
  end
  it "finds files relative to root of gem" do
    root_dir = Heel::Configuration.root_dir
    _(root_dir).must_equal @proj_root.expand_path.to_s + File::SEPARATOR
  end

  it "finds files in the config dir of the project" do
    config_rb = Heel::Configuration.config_path('config.rb')
    _(config_rb).must_equal @proj_root.join("config", "config.rb").to_s
  end

  it "finds files in the data dir of the project" do
    icons = Heel::Configuration.data_path('lineicons', 'icons')
    _(icons).must_equal @proj_root.join( "data", "lineicons", "icons" ).to_s
  end

  it "finds files in the lib dir of the project" do
    heel_rb = Heel::Configuration.lib_path('heel.rb')
    _(heel_rb).must_equal @proj_root.join("lib", "heel.rb").to_s
  end

end
