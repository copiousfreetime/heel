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

            @options        = default_options
            @parsed_options = ::OpenStruct.new
            @parser         = option_parser

            begin
                @parser.parse!(argv)
            rescue OptionParse::ParseError => pe
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
                                        "(default: #{default_options.address}") do |add|
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
                    @parsed_options.document_root = document_root
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

        def error_version_help
            if @parsed_options.show_version then
                puts "#{@parser.program_name}: version #{Heel::VERSION.join(".")}"
                exit 0
            elsif @parsed_options.show_help then
                puts @parser.to_s
                exit 0
            end
        end

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

            puts "heel running at #{options.address}:#{options.port} with document root #{options.document_root}"
            config.join
        end
    end
end
