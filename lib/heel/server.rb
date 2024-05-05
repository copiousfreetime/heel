# frozen_string_literal: true

#--
# Copyright (c) 2007 - 2013 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license. See LICENSE for details
#++

require "ostruct"
require "launchy"
require "fileutils"
require "heel/rackapp"
require "rackup"
require "puma"

module Heel
  # Internal: The heel server
  #
  class Server
    attr_accessor :options

    attr_reader :stdout, :stderr, :stdin

    # Class holding the results of the commandline options
    Options = Struct.new(:show_version, :show_help, :address, :port,
                         :document_root, :daemonize, :highlighting,
                         :kill, :launch_browser, keyword_init: true)

    class << self
      # Switch to more modern ways of finding the home directory
      def home_directory # :nodoc:
        Dir.home || ENV.fetch("USERPROFILE", nil) || "/"
      end

      def default_options
        Options.new.tap do |defaults|
          defaults.show_version    = false
          defaults.show_help       = false
          defaults.address         = "0.0.0.0"
          defaults.port            = 4331
          defaults.document_root   = Dir.pwd
          defaults.daemonize       = false
          defaults.highlighting    = true
          defaults.kill            = false
          defaults.launch_browser  = true
        end
      end

      def default_directory
        ENV["HEEL_DEFAULT_DIRECTORY"] || File.join(::Heel::Server.home_directory, ".heel")
      end

      def win?
        RUBY_PLATFORM =~ /mswin|mingw/
      end

      def java?
        RUBY_PLATFORM.include?("java")
      end
    end

    def initialize(argv = [])
      argv ||= []

      set_io

      @options         = Server.default_options
      @parser          = option_parser
      @error_message   = nil

      begin
        @parser.parse!(argv)
      rescue ::OptionParser::ParseError => e
        msg = ["#{@parser.program_name}: #{e}",
               "Try `#{@parser.program_name} --help` for more information",]
        @error_message = msg.join("\n")
      end
    end

    def default_directory
      self.class.default_directory
    end

    def pid_file
      File.join(default_directory, "heel.#{options.port}.pid")
    end

    def log_file
      File.join(default_directory, "heel.#{options.port}.log")
    end

    def option_parser
      OptionParser.new do |op|
        op.separator ""

        op.on("-a", "--address ADDRESS", "Address to bind to",
              "  (default: #{Server.default_options.address})") do |add|
                @options.address = add
              end

        op.on("-d", "--daemonize", "Run daemonized in the background") do
          raise ::OptionParser::ParseError, "Daemonizing is not supported on windows" if Server.win?
          raise ::OptionParser::ParseError, "Daemonizing is not supported on java" if Server.java?

          @options.daemonize = true
        end

        op.on("-h", "--help", "Display this text") do
          @options.show_help = true
        end

        op.on("-k", "--kill", "Kill an existing daemonized heel process") do
          @options.kill = true
        end

        op.on("--[no-]highlighting", "Turn on or off syntax highlighting",
              "  (default: off)") do |highlighting|
                @options.highlighting = highlighting
              end

        op.on("--[no-]launch-browser", "Turn on or off automatic browser launch",
              "  (default: on)") do |launch|
                @options.launch_browser = launch
              end

        op.on("-p", "--port PORT", Integer, "Port to bind to",
              "  (default: #{Server.default_options.port})") do |port|
                @options.port = port
              end

        op.on("-r", "--root ROOT",
              "Set the document root", " (default: #{Server.default_options.document_root})") do |document_root|
                @options.document_root = File.expand_path(document_root)
                unless File.directory?(@options.document_root)
                  raise ::OptionParser::ParseError,
                        "#{@options.document_root} is not a valid directory"
                end
              end

        op.on("-v", "--version", "Show version") do
          @options.show_version = true
        end
      end
    end

    # set the IO objects in a single method call.  This is really only for testing
    # instrumentation
    def set_io(stdin = $stdin, stdout = $stdout, stderr = $stderr)
      @stdin  = stdin
      @stdout = stdout
      @stderr = stderr
    end

    # if Version or Help options are set, then output the appropriate information instead of
    # running the server.
    def error_version_help_kill
      if @options.show_version
        @stdout.puts "#{@parser.program_name}: version #{Heel::VERSION}"
        exit 0
      elsif @options.show_help
        @stdout.puts @parser.to_s
        exit 0
      elsif @error_message
        @stdout.puts @error_message
        exit 1
      elsif @options.kill
        kill_existing_proc
      end
    end

    # kill an already running background heel process
    def kill_existing_proc
      if File.exist?(pid_file)
        begin
          pid = File.read(pid_file).to_i
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
      return if File.exist?(default_directory)

      FileUtils.mkdir_p(default_directory)
      @stdout.puts "Created #{default_directory}"
      @stdout.puts "heel's PID (#{pid_file}) and log file (#{log_file}) are stored here"
    end

    # make sure that if we are daemonizing the process is not running
    def ensure_not_running
      return unless File.exist?(pid_file)

      @stdout.puts "ERROR: PID File #{pid_file} already exists. Heel may already be running."
      @stdout.puts "ERROR: Check the Log file #{log_file}"
      @stdout.puts "ERROR: Heel will not start until the .pid file is cleared."
      @stdout.puts "ERROR: Execute `heel --kill --port #{options.port}' to clean it up."
      exit 1
    end

    def launch_browser
      Thread.new do
        print "Launching your browser"
        if options.daemonize
          puts " at http://#{options.address}:#{options.port}/"
        else
          puts "..."
        end
        ::Launchy.open("http://#{options.address}:#{options.port}/")
      end
    end

    def heel_app
      app = Heel::RackApp.new({ document_root: options.document_root,
                                highlighting: options.highlighting, })

      logger = Heel::Logger.new(log_file)

      stack = Rack::Builder.new do
        use Rack::CommonLogger, logger
        map "/" do
          run app
        end
        map "/__heel__/css" do
          run Rack::Files.new(Heel::Configuration.data_path("css"))
        end
        map "/__heel__/icons" do
          run Rack::Files.new(Heel::Configuration.data_path("icons"))
        end
      end
      stack.to_app
    end

    # If we are daemonizing the fork and wait for the child to launch the server
    # If we are not daemonizing, throw the ::Rackup::Server in a background thread
    def start_server
      return start_foreground_server unless options.daemonize

      start_background_server
      nil
    end

    def start_background_server
      if (cpid = fork)
        Process.waitpid(cpid)
      else
        server = ::Rackup::Server.new(server_options)
        server.start
      end
    end

    def start_foreground_server
      Thread.new do
        server = ::Rackup::Server.new(server_options)
        server.start
      end
    end

    def server_options
      {
        app: heel_app,
        pid: pid_file,
        Port: options.port,
        Host: options.address,
        environment: "none",
        server: "puma",
        daemonize: options.daemonize,
      }
    end

    # run the heel server with the current options.
    def run
      error_version_help_kill
      setup_heel_dir
      ensure_not_running

      server_thread = start_server

      launch_browser.join if options.launch_browser
      server_thread.join if server_thread
    end
  end
end
