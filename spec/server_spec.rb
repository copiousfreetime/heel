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
            @stdout.string.should == "heel: version #{Heel::VERSION}"
        end
    end
end