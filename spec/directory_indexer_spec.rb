require 'spec_helper'

describe Heel::DirectoryIndexer do
  before(:each) do
    @indexer = Heel::DirectoryIndexer.new(Heel::Configuration.data_path("listing.rhtml"), { highlighting: true })
  end

  it "should ignore .htaccess files" do
    @indexer.options[:ignore_globs] = %w(*~ .htaccess .)
    _(@indexer.should_ignore?(".htaccess")).must_equal true
  end

  it "should not ignore .html files " do
    @indexer.options[:ignore_globs] = %w(*~ .htaccess .)
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

  it "uses a mime map" do
    _(@indexer.mime_map).must_be_instance_of(Heel::MimeMap)
  end

  [
    { ext: 'svg', type: 'image/svg+xml' },
    { ext: 'flv', type: 'video/x-flv' },
    { ext: 'rb', type: 'text/plain' },
    { ext: 'rhtml', type: 'text/plain' },
  ].each do |m|
    it "finds #{m[:ext]} extension in the map as #{m[:type]}" do
      _(@indexer.mime_map.mime_type_of("test.#{m[:ext]}")).must_equal m[:type]
    end
  end

  %w[md markdown rdoc].each do |ext|
    it "finds #{ext} in the map as text/plain" do
      _(@indexer.mime_map.mime_type_of("test.#{ext}")).must_equal "text/plain"
    end
  end
end
