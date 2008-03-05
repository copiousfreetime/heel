require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))

require 'stringio'

describe Heel::DirHandler do 
    before(:each) do 
        @handler = Heel::DirHandler.new({:highlighting => true})
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
        @socket.string.should =~ /Index of/m
    end
    
    it "should return an existing directory index page if it exists" do
        File.open("index.html", "w") { |f| f.write('delete me') }
        @params[Mongrel::Const::REQUEST_URI] = "/"
        junk1,path_info,junk2 = @classifier.resolve(@params[Mongrel::Const::REQUEST_URI])
        
        @params[Mongrel::Const::PATH_INFO] = path_info
        @request = Mongrel::HttpRequest.new(@params,@socket,nil)
        
        @handler.process(@request,@response)
        @response.finished
        File.unlink("index.html")
        
        @response.status.should == 200
        @socket.string.should =~ /delete me/m
    end
    
    it "should return a 403 if a request for an ignorable file is made" do
        File.open(".htaccess", "w") { |f| f.write('delete me') }
        @params[Mongrel::Const::REQUEST_URI] = "/.htaccess"
        junk1,path_info,junk2 = @classifier.resolve(@params[Mongrel::Const::REQUEST_URI])
        
        @params[Mongrel::Const::PATH_INFO] = path_info
        @request = Mongrel::HttpRequest.new(@params,@socket,nil)
        
        @handler.process(@request,@response)
        @response.finished

        File.unlink(".htaccess")
        @response.status.should == 403
        
    end
    
    it "should return a 403 if an invalid request method is used" do
        @params[Mongrel::Const::REQUEST_METHOD] = "PUT"
        @params[Mongrel::Const::REQUEST_URI] = "/"
        junk1,path_info,junk2 = @classifier.resolve(@params[Mongrel::Const::REQUEST_URI])
        
        @params[Mongrel::Const::PATH_INFO] = path_info
        @request = Mongrel::HttpRequest.new(@params,@socket,nil)
        
        @handler.process(@request,@response)
        @response.finished

        @response.status.should == 403
        @socket.string.should =~ /Only HEAD and GET requests are honored./m
    end
    
    it "should format a ruby file and return it as a content-type text/html" do
        @params[Mongrel::Const::REQUEST_URI] = "/spec/" +  File.basename(__FILE__)
        junk1,path_info,junk2 = @classifier.resolve(@params[Mongrel::Const::REQUEST_URI])
        
        @params[Mongrel::Const::PATH_INFO] = path_info
        @request = Mongrel::HttpRequest.new(@params,@socket,nil)
        @handler.process(@request,@response)
        @response.finished
        @response.status.should == 200
        @socket.string.should =~ /Content-Type: text\/html/m
        
    end
    
    it "should parse the highlighting cgi parameter and return non-highlighted text if highlighting=off" do
        @params[Mongrel::Const::REQUEST_URI] = "/spec/" +  File.basename(__FILE__)
        @params['QUERY_STRING'] = "highlighting=off"
        junk1,path_info,junk2 = @classifier.resolve(@params[Mongrel::Const::REQUEST_URI])
        
        @params[Mongrel::Const::PATH_INFO] = path_info
        @request = Mongrel::HttpRequest.new(@params,@socket,nil)
        @handler.process(@request,@response)
        @response.finished
        @response.status.should == 200
        @socket.string.should =~ /Content-Type: text\/plain/m
    end
    
    it "should return icons appropriately for unknown mime_type" do
        @handler.icon_for(MIME::Types.of("stuff.svg").first).should == "page_white.png"
    end
    
    it "should test if templates need to be reloaded" do
        @handler.reload_template_changes?.should == false
    end
    
    it "should return 403 if we access something that exists but is not a readable file" do
        File.open("deleteme.html", "w") { |f| f.write('delete me') }
        File.chmod(0111, "deleteme.html")
        @params[Mongrel::Const::REQUEST_URI] = "/deleteme.html"
        junk1,path_info,junk2 = @classifier.resolve(@params[Mongrel::Const::REQUEST_URI])
        
        @params[Mongrel::Const::PATH_INFO] = path_info
        @request = Mongrel::HttpRequest.new(@params,@socket,nil)
        
        @handler.process(@request,@response)
        @response.finished
        File.unlink("deleteme.html")

        @response.status.should == 403
    end       
end
