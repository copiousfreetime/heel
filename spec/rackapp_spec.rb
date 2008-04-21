require 'spec/spec_helper'
require 'rack/mock'
require 'heel/rackapp'

describe Heel::RackApp do
  before(:each) do
    @app = Heel::RackApp.new( { :highlighting => 'true' } )
    @request = Rack::MockRequest.new(@app)
  end

  it "should return the a listing for the currrent directory" do
    res = @request.get("/")
    res.should be_ok
    res['Content-Type'].should == "text/html"
    res.body.should =~ /Rakefile/
  end

  it 'should highlight a ruby file' do
    res = @request.get("/gemspec.rb")
    res.should be_ok
    res['Content-Type'].should == "text/html"
    res.body.should =~ /class="CodeRay"/
  end

  it "should not highlight a ruby file if told not to" do
    res = @request.get("/gemspec.rb?highlighting=off")
    res.should be_ok
    res.body.size.should == File.size("gemspec.rb")
    res['Content-Type'].should == "text/plain"
  end

  it "should return a 405 if given a non-GET request" do
    res = @request.post("/")
    res.should_not be_ok
    res.status.should == 405
  end

  it "should return a 403 if accessing an invalid location" do
    res = @request.get("/../../../../etc/passwd")
    res.should_not be_ok
    res.status.should == 403
  end
end
