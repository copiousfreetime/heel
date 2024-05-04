# frozen_string_literal: true

require 'spec_helper'
require 'rack/mock'
require 'heel/rackapp'

describe Heel::RackApp do
  before(:each) do
    @app = Heel::RackApp.new({ highlighting: 'true' })
    @request = Rack::MockRequest.new(@app)
  end

  it "should return the a listing for the currrent directory" do
    res = @request.get("/")
    _(res).must_be :ok?
    _(res['Content-Type']).must_equal "text/html"
    _(res.body).must_match(/Rakefile/)
  end

  it 'should highlight a ruby file' do
    res = @request.get("/lib/heel.rb")
    _(res).must_be :ok?
    _(res['Content-Type']).must_equal "text/html"
    _(res.body).must_match(/class="highlight"/)
  end

  it "should not highlight a ruby file if told not to" do
    res = @request.get("/lib/heel.rb?highlighting=off")
    _(res).must_be :ok?
    _(res.body.size).must_equal File.size("lib/heel.rb")
    _(res['Content-Type']).must_equal "text/plain"
  end

  it "should return a 405 if given a non-GET request" do
    res = @request.post("/")
    _(res).wont_be :ok?
    _(res.status).must_equal 405
  end

  it "should return a 403 if accessing an invalid location" do
    res = @request.get("/../../../../etc/passwd")
    _(res).wont_be :ok?
    _(res.status).must_equal 403
  end
end
