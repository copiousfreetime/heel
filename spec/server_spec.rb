require "spec_helper"

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
    rescue SystemExit => e
      _(e.status).must_equal 0
      _(@stdout.string).must_match(/version #{Heel::VERSION}/o)
    end
  end

  it "should output the Usage when invoked with --help" do
    server = Heel::Server.new(["--help"])
    server.set_io(@stdin, @stdout)
    begin
      server.run
    rescue SystemExit => e
      _(e.status).must_equal 0
      _(@stdout.string).must_match(/Usage/m)
    end
  end

  it "should have an error when invoked with invalid parameters" do
    server = Heel::Server.new(["--junk"])
    server.set_io(@stdin, @stdout)
    begin
      server.run
    rescue SystemExit => e
      _(e.status).must_equal 1
      _(@stdout.string).must_match(/Try .*--help/m)
    end
  end

  it "should raise print an error if the directory to serve does not exist" do
    server = Heel::Server.new(%w[--root /not/valid])
    server.set_io(@stdin, @stdout)
    begin
      server.run
    rescue SystemExit => e
      _(e.status).must_equal 1
      _(@stdout.string).must_match(/Try .*--help/m)
    end
  end

  it "should allow port and address to be set" do
    server = Heel::Server.new(%w[--port 4242 --address 192.168.1.1])
    server.merge_options
    _(server.options.address).must_equal "192.168.1.1"
    _(server.options.port).must_equal 4242
  end

  it "should allow the highlighting option to be set" do
    server = Heel::Server.new(%w[--no-highlighting])
    server.merge_options
    _(server.options.highlighting).must_equal false
  end

  it "should have highlighting on as a default" do
    server = Heel::Server.new
    server.merge_options
    _(server.options.highlighting).must_equal true
  end

  it "should set no-launch-browser option" do
    server = Heel::Server.new(%w[--no-launch-browser])
    server.merge_options
    _(server.options.launch_browser).must_equal false
  end

  it "should attempt to kill the process" do
    server = Heel::Server.new(%w[--kill])
    server.set_io(@stdin, @stdout)

    begin
      server.run
      violated("Should have thrown SystemExit")
    rescue SystemExit => e
      _(e.status).must_equal 0
      _(@stdout.string).must_match(/Done/m)
    end
  end

  it "should setup a heel directory" do
    server = Heel::Server.new(%w[--daemonize])
    server.set_io(@stdin, @stdout)
    _(File.directory?(server.default_directory)).must_equal false
    server.setup_heel_dir
    _(File.directory?(server.default_directory)).must_equal true
    _(@stdout.string).must_match(/Created/m)
  end

  it "should send a signal to a pid" do
    server = Heel::Server.new(%w[--kil])
    server.set_io(@stdin, @stdout)
    server.setup_heel_dir

    File.write(server.pid_file, "-42")
    begin
      server.run
      violated("Should have exited")
    rescue SystemExit => e
      _(e.status).must_equal 0
      _(@stdout.string).must_match(/Sending TERM to process -42/m)
    end
  end

  it "records the port of the server process in the pid filename" do
    server = Heel::Server.new(%w[--port 4222])
    server.merge_options
    _(File.basename(server.pid_file)).must_equal("heel.4222.pid")
  end

  it "records the port of the server process in the log filename" do
    server = Heel::Server.new(%w[--port 4222])
    server.merge_options
    _(File.basename(server.log_file)).must_equal("heel.4222.log")
  end
end
