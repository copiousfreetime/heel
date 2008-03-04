module Heel
  # nothing more than a rack request with some additional methods
  class Request < ::Rack::Request

    attr_reader :root_dir

    def initialize(env, root_dir)
      super(env)
      @root_dir = root_dir
    end

    # a stat of the file mentioned in the request path
    #
    def stat
      @stat ||= ::File.stat(request_path) 
    end

    # normalize the request path to the full file path of the request from the
    # +root_dir+
    #
    def request_path
      puts "path_info = #{path_info}"
      @request_path ||= ::File.expand_path(::File.join(root_dir, ::Rack::Utils.unescape(path_info)))
    end

    # 
    def base_uri
      @base_uri ||= ::Rack::Utils.unescape(path_info)
    end


    # a request must be for something that below the root directory
    #
    def forbidden?
      x = request_path.index(root_dir) 
      puts "request path = #{request_path}, root_dir = #{root_dir}, x = #{x}"
      x != 0
    end

    # a request is only good for something that actually exists and is readable
    #
    def found?
      File.exist?(request_path) and (stat.directory? or stat.file?) and stat.readable?
    end

    def for_directory?
      stat.directory?
    end

    def for_file?
      stat.file?
    end

    # was the highlighting parameter true or false?
    #
    def highlighting?
      %[ off false ].include? self.GET['highlighting'].to_s.downcase
    end
  end
end
