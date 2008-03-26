require 'spec/spec_helper'

describe Heel::DirectoryIndexer do
  before(:each) do
    @indexer = Heel::DirectoryIndexer.new(Heel::Configuration.data_path("listing.rhtml"), { :highlighting => true })
  end

  it "should ignore .htaccess files" do
    @indexer.options[:ignore_globs] = %w( *~ .htaccess . )
    @indexer.should_ignore?(".htaccess").should == true
  end

  it "should not ignore .html files " do
    @indexer.options[:ignore_globs] = %w( *~ .htaccess . )
    @indexer.should_ignore?("something.html").should == false
  end

  it "can tell if highlighting is to be performed" do
    @indexer.should be_highlighting
  end
  
  it "knows if the template should be reloaded on changes" do
    @indexer.should_not be_reload_on_template_change
  end
  
  it "may or maynot use icons" do
    @indexer.should_not be_using_icons
  end

  it "uses a mime map" do
    @indexer.mime_map.should be_instance_of(Heel::MimeMap)
  end

end
