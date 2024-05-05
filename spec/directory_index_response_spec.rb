# frozen_string_literal: true

require "spec_helper"

describe Heel::DirectoryIndexResponse do
  before(:each) do
    @request = ::Heel::Request.new({}, ::Heel::Configuration.root_dir)
    @response = Heel::DirectoryIndexResponse.new(request: @request, options: { highlighting: true })
  end

  it "should ignore .htaccess files" do
    @response.options[:ignore_globs] = %w[*~ .htaccess .]
    _(@response.should_ignore?(".htaccess")).must_equal true
  end

  it "should not ignore .html files " do
    @response.options[:ignore_globs] = %w[*~ .htaccess .]
    _(@response.should_ignore?("something.html")).must_equal false
  end

  it "can tell if highlighting is to be performed" do
    _(@response).must_be :highlighting?
  end

  it "uses icons" do
    _(@response.using_icons?).must_equal false
  end
end
