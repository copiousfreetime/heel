require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))

describe Heel::ErrorHandler do 
    before(:each) do 
        @server = Heel::Server.new(%w[--directory /tmp])
    end
    
    it "should return the error page" do
        res = Net::HTTP.get_response(URI.parse("http://localhost:4331/does-not-exist"))
        res.code.should == "404"
        res.body.should =~ /Not Found/m
    end
end
