#--
# Copyright (c) 2007 - 2013 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license. See LICENSE for details
#++

require 'ostruct'
require 'launchy'
require 'fileutils'
require 'heel/rackapp'
require 'puma'

module Heel
  class Server

    attr_accessor :options
    attr_accessor :parsed_options

    attr_reader :stdout
    attr_reader :stderr
    attr_reader :stdin


    class << self
      # thank you Jamis - from Capistrano
      def home_directory # :nodoc:
        ENV["HOME"] ||
          (ENV["HOMEPATH"] && "#{ENV["HOMEDRIVE"]}#{ENV["HOMEPATH"]}") ||
                    "/"
      end
    end

    def initialize(argv = [])
      argv ||= []

      set_io

      @options         = default_options
      @parsed_options  = ::OpenStruct.new
      @parser          = option_parser
      @error_message   = nil

      begin
        @parser.parse!(argv)
      rescue ::OptionParser::ParseError => pe
        msg = ["#{@parser.program_name}: #{pe}",
               "Try `#{@parser.program_name} --help` for more information"]
        @error_message = msg.join("\n")
      end
    end

    def default_options
      defaults                 = ::OpenStruct.new
      defaults.show_version    = false
      defaults.show_help       = false
      defaults.address         = "0.0.0.0"
      defaults.port            = 4331
      defaults.document_root   = Dir.pwd
      defaults.daemonize       = false
      defaults.highlighting    = false
      defaults.kill            = false
      defaults.launch_browser  = true
      return defaults
    end

    def default_directory
      ENV["HEEL_DEFAULT_DIRECTORY"] || File.join(::Heel::Server.home_directory,".heel")
    end

    def pid_file
      File.join(default_directory,"heel.#{options.port}.pid")
    end

    def log_file
      File.join(default_directory,"heel.#{options.port}.log")
    end

    def win?
      RUBY_PLATFORM =~ /mswin|mingw/
    end

    def java?
      RUBY_PLATFORM =~ /java/
    end

    def option_parser
      OptionParser.new do |op|
        op.separator ""

        op.on("-a", "--address ADDRESS", "Address to bind to",
                                        "  (default: #{default_options.address})") do |add|
          @parsed_options.address = add
        end

        op.on("-d", "--daemonize", "Run daemonized in the background") do 
          raise ::OptionParser::ParseError, "Daemonizing is not supported on windows" if win?
          raise ::OptionParser::ParseError, "Daemonizing is not supported on java" if java?
          @parsed_options.daemonize = true
        end

        op.on("-h", "--help", "Display this text") do 
          @parsed_options.show_help = true
        end

        op.on("-k", "--kill", "Kill an existing daemonized heel process") do
          @parsed_options.kill = true
        end

        op.on("--[no-]highlighting", "Turn on or off syntax highlighting",
                                             "  (default: off)") do |highlighting|
          @parsed_options.highlighting = highlighting
        end

        op.on("--[no-]launch-browser", "Turn on or off automatic browser launch",
                                               "  (default: on)") do |l|
          @parsed_options.launch_browser = l
        end

        op.on("-p", "--port PORT", Integer, "Port to bind to",
                                        "  (default: #{default_options.port})") do |port|
          @parsed_options.port = port
        end

        op.on("-r","--root ROOT", 
                      "Set the document root"," (default: #{default_options.document_root})") do |document_root|
          @parsed_options.document_root = File.expand_path(document_root)
          raise ::OptionParser::ParseError, "#{@parsed_options.document_root} is not a valid directory" if not File.directory?(@parsed_options.document_root)
        end

        op.on("-v", "--version", "Show version") do 
          @parsed_options.show_version = true
        end
      end
    end

    def merge_options
      options = default_options.marshal_dump
      options.merge!( @parsed_options.marshal_dump )

      @options = OpenStruct.new(options)
    end

    # set the IO objects in a single method call.  This is really only for testing 
    # instrumentation
    def set_io(stdin = $stdin, stdout = $stdout ,setderr = $stderr)
      @stdin  = stdin
      @stdout = stdout
      @stderr = stderr
    end

    # if Version or Help options are set, then output the appropriate information instead of 
    # running the server.
    def error_version_help_kill
      if @parsed_options.show_version then
        @stdout.puts "#{@parser.program_name}: version #{Heel::VERSION}"
        exit 0
      elsif @parsed_options.show_help then
        @stdout.puts @parser.to_s
        exit 0
      elsif @error_message then
        @stdout.puts @error_message
        exit 1
      elsif @parsed_options.kill then
        kill_existing_proc
      end
    end

    # kill an already running background heel process
    def kill_existing_proc
      if File.exists?(pid_file) then
        begin
          pid = open(pid_file).read.to_i
          @stdout.puts "Sending TERM to process #{pid}"
          Process.kill("TERM", pid)
        rescue Errno::ESRCH
          @stdout.puts "Unable to kill process with pid #{pid}.  Process does not exist.  Removing stale pid file."
          File.unlink(pid_file)
        rescue Errno::EPERM
          @stdout.puts "Unable to kill process with pid #{pid}.  No permissions to kill process."
        end
      else
        @stdout.puts "No pid file exists for server running on port #{options.port}, no process to kill"
      end
      @stdout.puts "Done."
      exit 0
    end

    # setup the directory that heel will use as the location to run from, where its logs will
    # be stored and its PID file if backgrounded.
    def setup_heel_dir
      if not File.exists?(default_directory) then
        FileUtils.mkdir_p(default_directory)
        @stdout.puts "Created #{default_directory}"
        @stdout.puts "heel's PID (#{pid_file}) and log file (#{log_file}) are stored here"
      end
    end

    # make sure that if we are daemonizing the process is not running
    def ensure_not_running
      if File.exist?(pid_file) then
        @stdout.puts "ERROR: PID File #{pid_file} already exists. Heel may already be running."
        @stdout.puts "ERROR: Check the Log file #{log_file}"
        @stdout.puts "ERROR: Heel will not start until the .pid file is cleared (`heel --kill --port #{options.port}' to clean it up)."
        exit 1
      end
    end

    def launch_browser
      Thread.new do
        print "Launching your browser"
        if options.daemonize then
          puts " at http://#{options.address}:#{options.port}/"
        else
          puts "..."
        end
        ::Launchy.open("http://#{options.address}:#{options.port}/")
      end
    end

    def heel_app
      app = Heel::RackApp.new({ :document_root => options.document_root,
                                :highlighting  => options.highlighting})

      logger = Heel::Logger.new( log_file )

      stack = Rack::Builder.new {
        use Rack::CommonLogger, logger
        map "/" do
          run app
        end
        map "/heel_css" do 
          run Rack::File.new(Heel::Configuration.data_path( "css" )) 
        end
        map "/heel_icons" do
          run Rack::File.new(Heel::Configuration.data_path("famfamfam", "icons")) 
        end
      }
      return stack.to_app
    end

    # If we are daemonizing the fork and wait for the child to launch the server
    # If we are not daemonizing, throw the Rack::Server in a background thread
    def start_server
      if options.daemonize then
        start_background_server
        return nil
      else
        return start_foreground_server
      end
    end

    def start_background_server
      if cpid = fork then
        Process.waitpid( cpid )
      else
        server = Rack::Server.new( server_options )
        server.start
      end
    end

    def start_foreground_server
      Thread.new {
        server = Rack::Server.new( server_options )
        server.start
      }
    end

    def server_options
      {
        :app  => heel_app,
        :pid  => pid_file,
        :Port => options.port,
        :Host => options.address,
        :environment => 'none',
        :server => 'puma',
        :daemonize => options.daemonize
      }
    end

    # run the heel server with the current options.
    def run

      merge_options
      error_version_help_kill
      setup_heel_dir
      ensure_not_running

      server_thread = start_server

      if options.launch_browser then
        launch_browser.join
      end
      server_thread.join if server_thread
    end
  end
end
