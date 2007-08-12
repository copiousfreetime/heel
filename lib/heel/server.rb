require 'heel'
require 'ostruct'

module Heel
    class Server

        attr_accessor :options
        attr_accessor :parsed_options

        attr_reader :stdout
        attr_reader :stderr
        attr_reader :stdin

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
                @default_options.address         = "0.0.0.0"
                @default_options.port            = 4331
                @default_options.document_root   = Dir.pwd
                @default_options.daemonize       = false
            end
            return @default_options
        end

        def option_parser
            OptionParser.new do |op|
                op.separator ""

                op.on("-a", "--address ADDRESS", "Address to bind to",
                                        "(default: #{default_options.address})") do |add|
                    @parsed_options.address = add
                end

                op.on("-d", "--daemonize", "Run daemonized in the background") do 
                    @parsed_options.daemonize = true
                end

                op.on("-h", "--help", "Display this text") do 
                    @parsed_options.show_help = true
                end

                op.on("-p", "--port PORT", Integer, "Port to bind to",
                                        "(default: #{default_options.port})") do |port|
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
        def error_version_help
            if @parsed_options.show_version then
                @stdout.puts "#{@parser.program_name}: version #{Heel::VERSION}"
                exit 0
            elsif @parsed_options.show_help then
                @stdout.puts @parser.to_s
                exit 0
            elsif @error_message then
                @stdout.puts @error_message
                exit 1
            end
        end

        # run the heel server with the current options.
        def run
            error_version_help
            merge_options
            document_root = options.document_root
            stats = ::Mongrel::StatisticsFilter.new(:sample_rate => 1)
            config = ::Mongrel::Configurator.new :host => options.address, :port => options.port do
                listener do
                    uri "/", :handler => stats
                    uri "/", :handler => Heel::DirHandler.new({:document_root => document_root})
                    uri "/", :handler => Heel::ErrorHandler.new
                    uri "/icons", :handler => Heel::DirHandler.new({ :document_root => 
                                                                          File.join(APP_RESOURCE_DIR, "famfamfam", "icons")})
                    uri "/status", :handler => ::Mongrel::StatusHandler.new(:stats_filter => stats)
                end
                setup_signals
                run
            end

            @stdout.puts "heel running at http://#{options.address}:#{options.port} with document root #{options.document_root}"
            config.join
        end
        
    end
end
