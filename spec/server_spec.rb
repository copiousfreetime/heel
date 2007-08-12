require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))
describe Heel::Server do
    before(:each) do 
        @stdin = StringIO.new
        @stdout = StringIO.new
        @stderr = StringIO.new
    end
    
    it "should output the version when invoked with --version" do
        server = Heel::Server.new(["--version"])
        server.set_io(@stdin, @stdout)
        begin
            server.run
        rescue SystemExit => se
            se.status.should == 0
            @stdout.string.should =~ /version #{Heel::VERSION}/
        end
    end
    
    it "should output the Usage when invoked with --help" do
        server = Heel::Server.new(["--help"])
        server.set_io(@stdin, @stdout)
        begin
            server.run
        rescue SystemExit => se
            se.status.should == 0
            @stdout.string.should =~ /Usage/m
        end
    end
    
    it "should have an error when invoked with invalid parameters" do
        server = Heel::Server.new(["--junk"])
        server.set_io(@stdin,@stdout)
        begin
            server.run
        rescue SystemExit => se
            se.status.should == 1
            @stdout.string.should =~ /Try .*--help/m
        end
    end
    
    it "should raise print an error if the directory to serve does not exist" do
        server = Heel::Server.new(["--root /not/valid"])
        server.set_io(@stdin,@stdout)
        begin
            server.run
        rescue SystemExit => se
            se.status.should == 1
            @stdout.string.should =~ /Try .*--help/m
        end
    end
        
end