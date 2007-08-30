require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))

require 'stringio'

describe Heel::DirHandler do 
    before(:each) do 
        @handler = Heel::DirHandler.new
        @classifier = Mongrel::URIClassifier.new
        @classifier.register("/",1)
        @socket = StringIO.new
        @params = Mongrel::HttpParams.new
        @params.http_body = ""
        @params[Mongrel::Const::REQUEST_METHOD] = Mongrel::Const::GET
        @response = Mongrel::HttpResponse.new(@socket)
        
    end
        
    it "should return the index page" do
        @params[Mongrel::Const::REQUEST_URI] = "/"
        junk1,path_info,junk2 = @classifier.resolve(@params[Mongrel::Const::REQUEST_URI])
        
        @params[Mongrel::Const::PATH_INFO] = path_info
        @request = Mongrel::HttpRequest.new(@params,@socket,nil)
        
        @handler.process(@request,@response)
        @response.finished
        
        @response.status.should == 200
        @response.body.string.should =~ /Index of/m
    end
    
    it "should return icons appropriately for unknown mime_type" do
        @handler.icon_for(MIME::Types.of("stuff.svg").first).should == "page_white.png"
    end
    
    it "should test if templates need to be reloaded" do
        @handler.reload_template_changes?.should == false
    end
end