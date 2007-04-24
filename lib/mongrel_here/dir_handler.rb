require 'rubygems'
require 'mime/types'
require 'erb'

module MongrelHere

    # A refactored version of Mongrel::DirHandler using the mime-types
    # gem and a prettier directory listing.
    class DirHandler < Mongrel::HttpHandler
        attr_reader :document_root
        attr_reader :directory_index_html
        attr_reader :icon_uri
        attr_reader :directory_listing_template
        attr_reader :default_mime_type
        attr_reader :ignore_globs

        # if any other mime types are needed, add them directly via the
        # mime-types calls.
        ADDITIONAL_MIME_TYPES = [
            # [ content-type , [ array, of, filename, extentions] ]
            ["images/svg+xml", ["svg"]],
            ["video/x-flv", ["flv"]],
            ["application/x-shockwave-flash", ["swf"]]
        ]

        def initialize(options = {})
            @ignore_globs               = options[:ignore_globs] || %w( *~ .htaccess . )
            @document_root              = options[:document_root] || Dir.pwd
            @directory_listing_allowed  = options[:directory_listing_allowed] || true
            @directory_index_html       = options[:directory_index_html] || "index.html"
            @using_icons                = options[:using_icons] || false
            @icon_url                   = options[:icon_url] || "/icons"
            @directory_listing_template = ::ERB.new File.read(File.join(APP_DATA_DIR,"listing.rhtml"))

            ADDITIONAL_MIME_TYPES.each do |mt|
                if MIME::Types[mt.first].nil? then
                    type = MIME::Type.from_array(mt)
                    MIME::Types.add(type)
                end
            end

            @default_mime_type = MIME::Types["application/octet-stream"].first
        end

        def directory_listing_allowed?
            return @directory_listing_allowed
        end

        def using_icons?
            return @using_icons
        end

        # determine how to respond to the request, it will either be a
        # directory listing, a file return, or an error return.
        def how_to_respond(req_path)
            if req_path.index(document_root) == 0 then
                begin
                    stat = File.stat(req_path)
                    if stat.directory? then
                       dir_index = File.join(req_path,directory_index_html)
                       if File.exists?(dir_index) then
                           return dir_index
                       elsif directory_listing_allowed?
                           return :directory_listing
                       end
                    elsif stat.file? and stat.readable? then
                        if should_ignore?(File.basename(req_path)) then
                            return 403
                        end
                        return req_path
                    else
                        # TODO: debug log
                        return 403
                    end

                rescue => error
                    # TODO: debug log
                    return 404
                end
            else
               return 403
            end
        end

        def should_ignore?(fname)
            ignore_globs.each do |glob|
                return true if File.fnmatch(glob,fname)
            end
            false 
        end

        # send a directory listing back to the client
        def respond_with_directory_listing(req_path,request,response)
            base_uri = ::Mongrel::HttpRequest.unescape(request.params[Mongrel::Const::REQUEST_URI])
            entries = []
            Dir.entries(req_path).each do |entry|
                next if should_ignore?(entry)
                next if req_path == document_root and entry == ".."
                stat            = File.stat(File.join(req_path,entry))
                entry_data      = OpenStruct.new 

                entry_data.name          = entry
                entry_data.size          = num_to_bytes(stat.size)
                entry_data.last_modified = stat.mtime.strftime("%Y-%m-%d %H:%M:%S")

                if stat.directory? then
                    entry_data.mime_type = "Directory"
                    entry_data.size      = "-"
                else
                    entry_data.mime_type = (MIME::Types.of(entry).first || default_mime_type).to_s
                end
                
                if using_icons? then
                    entry_data.icon_url = File.join(icon_url, icon_for(entry_data.type))
                end
                entries << entry_data
            end

            entries = entries.sort_by { |e| e.name }

            response.start(200) do |head,out|
                head['Content-Type'] = 'text/html'
                out.write(directory_listing_template.result(binding))
            end
        end

        # this method is essentially the send_file method from
        # Mongrel::DirHandler
        def respond_with_send_file(path,method,request,response)
            stat    = File.stat(path)
            mtime   = stat.mtime
            etag    = ::Mongrel::Const::ETAG_FORMAT % [mtime.to_i, stat.size, stat.ino]

            modified_since  = request.params[::Mongrel::Const::HTTP_IF_MODIFIED_SINCE]
            none_match      = request.params[::Mongrel::Const::HTTP_IF_NONE_MATCH]

            last_response_time = Time.httpddate(modified_since) rescue nil

            same_response = case
                            when modified_since && !last_response_time                               : false
                            when modified_since && last_response_time > Time.now                     : false
                            when modified_since && mtime > last_response_time                        : false
                            when none_match     && none_match == "*"                                 : false
                            when none_match     && !none_match.strip.split(/\s*,\s*/).include?(etag) : false
                            else modified_since || none_match
                            end
            header = response.header
            header[::Mongrel::Const::ETAG] = etag

            if same_response then
                response.start(304) {}
            else
                response.status = 200
                header[::Mongrel::Const::LAST_MODIFIED] = mtime.httpdate
                header[::Mongrel::Const::CONTENT_TYPE] = (MIME::Types.of(path).first || default_mime_type).to_s
            end

            response.send_status(stat.size)
            response.send_header

            if method == ::Mongrel::Const::GET then
                response.send_file(path,stat.size < ::Mongrel::Const::CHUNK_SIZE * 2)
            end
        end

        # process the request, returning either the file, a directory
        # listing (if allowed) or an appropriate error
        def process(request, response)
            method   = request.params[Mongrel::Const::REQUEST_METHOD] || Mongrel::Const::GET
            if ( method == Mongrel::Const::GET ) or ( method == Mongrel::Const::HEAD ) then
                
                req_path = File.expand_path(File.join(@document_root,
                                                      ::Mongrel::HttpRequest.unescape(request.params[Mongrel::Const::PATH_INFO])),
                                            @document_root)
                res_type = how_to_respond(req_path)

                case res_type 
                when :directory_listing
                    respond_with_directory_listing(req_path,request,response)
                when String
                    respond_with_send_file(res_type,method,request,response)
                when Integer
                    response.status = res_type
                end

            # invalid method
            else
                response.start(403) { |head,out| out.write("Only HEAD and GET requests are honored.") }
            end
        end

        # essentially this is strfbytes from facets
        def num_to_bytes(num,fmt="%.2f")
           case
            when num < 1024
              "#{num} bytes"
            when num < 1024**2
              "#{fmt % (num.to_f / 1024)} KB"
            when num < 1024**3
              "#{fmt % (num.to_f / 1024**2)} MB"
            when num < 1024**4
              "#{fmt % (num.to_f / 1024**3)} GB"
            when num < 1024**5
              "#{fmt % (num.to_f / 1024**4)} TB"
            else
              "#{num} bytes"
            end
        end
    end
end
