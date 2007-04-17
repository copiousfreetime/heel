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
            @parsed_options = OpenStruct.new
            @parser         = self.option_parser

            begin
                @parser.parse!(argv)
            rescue OptionParse::ParseError => pe
            end
        end

        def default_options
            options = OpenStruct.new
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

                op.on("-h", "--help") do 
                    @parsed_options.show_help = true
                end

                op.on("-pPORT", "--port PORT", Integer,
                      "Port to bind to (default: 4323)") do |port|
                    @parsed_options.port = port
                end

                op.on("-rROOT","--root ROOT", 
                      "Set the document root (default: #{Dir.pwd})") do |document_root|
                    @parsed_options.document_root = document_root
               end

                op.on("-d", "--daemonize", "Run daemonized in the background") do 
                    @parsed_options.daemonize = true
                end

                op.on("-v", "--version", "Show version") do 
                    @parsed_options.show_version = true
                end
            end
        end
    end
end
