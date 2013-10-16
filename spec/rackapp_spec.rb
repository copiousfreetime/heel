require 'spec_helper'
require 'rack/mock'
require 'heel/rackapp'

describe Heel::RackApp do
  before(:each) do
    @app = Heel::RackApp.new( { :highlighting => 'true' } )
    @request = Rack::MockRequest.new(@app)
  end

  it "should return the a listing for the currrent directory" do
    res = @request.get("/")
    res.must_be :ok?
    res['Content-Type'].must_equal "text/html"
    res.body.must_match( /Rakefile/ )
  end

  it 'should highlight a ruby file' do
    res = @request.get("/lib/heel.rb")
    res.must_be :ok?
    res['Content-Type'].must_equal "text/html"
    res.body.must_match( /class="CodeRay"/ )
  end

  it "should not highlight a ruby file if told not to" do
    res = @request.get("/lib/heel.rb?highlighting=off")
    res.must_be :ok?
    res.body.size.must_equal File.size("lib/heel.rb")
    res['Content-Type'].must_equal "text/plain"
  end

  it "should return a 405 if given a non-GET request" do
    res = @request.post("/")
    res.wont_be :ok?
    res.status.must_equal 405
  end

  it "should return a 403 if accessing an invalid location" do
    res = @request.get("/../../../../etc/passwd")
    res.wont_be :ok?
    res.status.must_equal 403
  end
end
