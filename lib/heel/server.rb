require 'heel'
require 'ostruct'
require 'launchy'
require 'tmpdir'
require 'fileutils'

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
            
            @options        = default_options
            @parsed_options = ::OpenStruct.new
            @parser         = option_parser
            @error_message  = nil

            begin
                @parser.parse!(argv)
            rescue ::OptionParser::ParseError => pe
                msg = ["#{@parser.program_name}: #{pe}",
                        "Try `#{@parser.program_name} --help` for more information"]
                @error_message = msg.join("\n")
            end
        end

        def default_options
            if @default_options.nil? then
                @default_options                 = ::OpenStruct.new
                @default_options.show_version    = false
                @default_options.show_help       = false
                @default_options.address         = "127.0.0.1"
                @default_options.port            = 4331
                @default_options.document_root   = Dir.pwd
                @default_options.daemonize       = false
                @default_options.highlighting    = true
                @default_options.kill            = false
                @default_options.launch_browser  = true
            end
            return @default_options
        end
        
        def default_directory
            ENV["HEEL_DEFAULT_DIRECTORY"] || File.join(::Heel::Server.home_directory,".heel")
        end
        
        def pid_file
            File.join(default_directory,"heel.pid")
        end
        
        def log_file
            File.join(default_directory,"heel.log")
        end

        def option_parser
            OptionParser.new do |op|
                op.separator ""

                op.on("-a", "--address ADDRESS", "Address to bind to",
                                        "  (default: #{default_options.address})") do |add|
                    @parsed_options.address = add
                end

                op.on("-d", "--daemonize", "Run daemonized in the background") do 
                    @parsed_options.daemonize = true
                end

                op.on("-h", "--help", "Display this text") do 
                    @parsed_options.show_help = true
                end
                
                op.on("-k", "--kill", "Kill an existing daemonized heel process") do
                    @parsed_options.kill = true
                end
                
                op.on("--[no-]highlighting", "Turn on or off syntax highlighting",
                                             "  (default: on)") do |highlighting|
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
            @parsed_options.marshal_dump.each_pair do |key,value|
                options[key] = value
            end

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
                    @stdout.puts "Process does not exist. Removing stale pid file."
                    File.unlink(pid_file)
                end
            else
                @stdout.puts "No pid file exists, no process to kill"
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

        # run the heel server with the current options.
        def run
            
            error_version_help_kill
            merge_options
            setup_heel_dir
            
            # capture method/variables into a local context so they can be used inside the Configurator block
            c_address       = options.address
            c_port          = options.port
            c_document_root = options.document_root
            c_background_me = options.daemonize
            c_default_dir   = default_directory
            c_highlighting  = options.highlighting
            c_pid_file      = pid_file
            c_log_file      = log_file

            stats = ::Mongrel::StatisticsFilter.new(:sample_rate => 1)
            config = ::Mongrel::Configurator.new(:host => options.address, :port => options.port, :pid_file => c_pid_file) do
                if c_background_me then
                    if File.exists?(c_pid_file) then
                        log "ERROR: PID File #{c_pid_file} already exists.  Heel may already be running."
                        log "ERROR: Check the Log file #{c_log_file}"
                        log "ERROR: Heel will not start until the .pid file is cleared (`heel --kill' to clean it up)."
                        exit 1
                    end
                    daemonize({:cwd => c_default_dir, :log_file => c_log_file})
                end
                
                begin
                    
                    listener do
                        uri "/", :handler => stats
                        uri "/", :handler => Heel::DirHandler.new({:document_root => c_document_root, 
                                                                   :highlighting => c_highlighting })
                        uri "/", :handler => Heel::ErrorHandler.new
                        uri "/css", :handler => Heel::DirHandler.new({:document_root =>
                                                                              File.join(APP_RESOURCE_DIR, "css")})
                        uri "/icons", :handler => Heel::DirHandler.new({ :document_root => 
                                                                              File.join(APP_RESOURCE_DIR, "famfamfam", "icons")})
                        uri "/status", :handler => ::Mongrel::StatusHandler.new(:stats_filter => stats)
                    end
                rescue Errno::EADDRINUSE
                    log "ERROR: Address (#{c_address}:#{c_port}) is already in use, please check running processes or run `heel --kill'"
                    exit 1
                end
                setup_signals
            end
            
            config.run
            config.log "heel running at http://#{options.address}:#{options.port} with document root #{options.document_root}"
                        
            if c_background_me then
                config.write_pid_file
            else
                config.log "Use Ctrl-C to stop."
            end
            
            if options.launch_browser then
                config.log "Launching your browser..."
                if c_background_me then
                    puts "Launching your browser to http://#{options.address}:#{options.port}/"
                end
                ::Launchy.open("http://#{options.address}:#{options.port}/")
            end
            
            config.join
            
        end
        
    end
end
