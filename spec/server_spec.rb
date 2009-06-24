require "spec/spec_helper"
describe Heel::Server do
  before(:each) do 
    @stdin = StringIO.new
    @stdout = StringIO.new
    @stderr = StringIO.new
    ENV["HEEL_DEFAULT_DIRECTORY"] = "/tmp/heel"
  end

  after(:each) do
    ENV.delete("HEEL_DEFAULT_DIRECTORY")
    FileUtils.rm_rf "/tmp/heel"
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
    server = Heel::Server.new(%w[--root /not/valid])
    server.set_io(@stdin,@stdout)
    begin
      server.run
    rescue SystemExit => se
      se.status.should == 1
      @stdout.string.should =~ /Try .*--help/m
    end
  end

  it "should allow port and address to be set" do
    server = Heel::Server.new(%w[--port 4242 --address 192.168.1.1])
    server.merge_options
    server.options.address.should == "192.168.1.1"
    server.options.port.should == 4242        
  end

  it "should allow the highlighting option to be set" do
    server = Heel::Server.new(%w[--highlighting])
    server.merge_options
    server.options.highlighting.should == true
  end

  it "should have highlighting off as a default" do
    server = Heel::Server.new
    server.merge_options
    server.options.highlighting.should == false
  end

  it "should set no-launch-browser option and kill option" do
    server = Heel::Server.new(%w[--no-launch-browser])
    server.merge_options
    server.options.launch_browser.should == false
  end

  it "should attempt to kill the process" do
    server = Heel::Server.new(%w[--kill])
    server.set_io(@stdin,@stdout)

    begin
      server.run
      violated("Should have thrown SystemExit")
    rescue SystemExit => se
      se.status.should == 0
      @stdout.string.should =~ /Done/m
    end
  end

  it "should setup a heel directory" do
    server = Heel::Server.new(%w[--daemonize])
    server.set_io(@stdin,@stdout)
    File.directory?(server.default_directory).should == false
    server.setup_heel_dir
    File.directory?(server.default_directory).should == true
    @stdout.string.should =~ /Created/m
  end

  it "should send a signal to a pid" do
    server = Heel::Server.new(%w[--kil])
    server.set_io(@stdin,@stdout)
    server.setup_heel_dir

    File.open(server.pid_file,"w+") { |f| f.write("-42") }
    begin
      server.run
      violated("Should have exited")
    rescue SystemExit => se
      se.status.should == 0
      @stdout.string.should =~ /Sending TERM to process -42/m
    end
  end
end
