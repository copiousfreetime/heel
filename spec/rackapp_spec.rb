require 'spec/spec_helper'
require 'rack/mock'
require 'heel/rackapp'

describe Heel::RackApp do
  before(:each) do
    @app = Heel::RackApp.new( { :highlighting => 'true' } )
    @request = Rack::MockRequest.new(@app)
  end

  it "should return the a listing fo the currrent directory" do
    res = @request.get("/")
    res.should be_ok
    res[:content_type].should == "text/html"
  end
end
