require 'ostruct'
require 'mongrel_here'

module MongrelHere
    class Server
        attr_accessor :options
        attr_accessor :parsed_options

        attr_reader :stdout
        attr_reader :stderr
        attr_reader :stdin

        def initialize(argv = [])
            argv ||= []

            @options        = self.default_options
            @parsed_options = ::OpenStruct.new
            @parser         = self.option_parser

            begin
                @parser.parse!(argv)
            rescue OptionParse::ParseError => pe
            end
        end

        def default_options
            options = ::OpenStruct.new
            options.show_version    = false
            options.show_help       = false
            options.port            = 4323
            options.root            = Dir.pwd
            options.daemonize       = false
            return options
        end

        def option_parser
            OptionParser.new do |op|
                op.separator ""

                op.on("-d", "--daemonize", "Run daemonized in the background") do 
                    @parsed_options.daemonize = true
                end

                op.on("-h", "--help", "Display this text") do 
                    @parsed_options.show_help = true
                end

                op.on("-pPORT", "--port PORT", Integer,
                      "Port to bind to (default: 4323)") do |port|
                    @parsed_options.port = port
                end

                op.on("-rROOT","--root ROOT", 
                      "Set the document root"," (default: #{Dir.pwd})") do |document_root|
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
                puts "#{@parser.program_name}: version #{MongrelHere::VERSION.join(".")}"
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
            config = ::Mongrel::Configurator.new :host => "*", :port => options.port do
                listener do
                    uri "/", :handler => stats
                    uri "/", :handler => MongrelHere::DirHandler.new({:document_root => document_root})
                    uri "/", :handler => MongrelHere::ErrorHandler.new
                    uri "/icons", :handler => MongrelHere::DirHandler.new({ :document_root => 
                                                                          File.join(APP_DATA_DIR, "famfamfam", "icons")})
                    uri "/status", :handler => Mongrel::StatusHandler.new(:stats_filter => stats)
                end
                setup_signals
                run
            end

            puts "mongrel_here running on port #{options.port} with document root #{options.document_root}"
            config.join
        end
    end
end
