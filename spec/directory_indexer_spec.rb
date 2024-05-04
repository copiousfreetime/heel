# frozen_string_literal: true

require "spec_helper"

describe Heel::DirectoryIndexer do
  before(:each) do
    @indexer = Heel::DirectoryIndexer.new(Heel::Configuration.data_path("listing.rhtml"), { highlighting: true })
  end

  it "should ignore .htaccess files" do
    @indexer.options[:ignore_globs] = %w[*~ .htaccess .]
    _(@indexer.should_ignore?(".htaccess")).must_equal true
  end

  it "should not ignore .html files " do
    @indexer.options[:ignore_globs] = %w[*~ .htaccess .]
    _(@indexer.should_ignore?("something.html")).must_equal false
  end

  it "can tell if highlighting is to be performed" do
    _(@indexer).must_be :highlighting?
  end

  it "knows if the template should be reloaded on changes" do
    _(@indexer.reload_on_template_change?).must_equal false
  end

  it "uses icons" do
    _(@indexer.using_icons?).must_equal false
  end
end
