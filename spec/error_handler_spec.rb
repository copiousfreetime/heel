require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))

describe Heel::ErrorHandler do 
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
    
    it "should return the error page" do        
        @params[Mongrel::Const::REQUEST_URI] = "/does-not-exist"
        junk1,path_info,junk2 = @classifier.resolve(@params[Mongrel::Const::REQUEST_URI])
        
        @params[Mongrel::Const::PATH_INFO] = path_info
        @request = Mongrel::HttpRequest.new(@params,@socket,nil)
        
        @handler.process(@request,@response)
        @response.finished
        @response.status.should == 404
        @socket.string.should =~ /Not Found/m
        
    end
end
