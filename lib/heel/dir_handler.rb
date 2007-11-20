require 'heel'
require 'mime/types'
require 'erb'
require 'coderay'
require 'coderay/helpers/file_type'

module Heel

    # A refactored version of Mongrel::DirHandler using the mime-types
    # gem and a prettier directory listing.
    class DirHandler < ::Mongrel::HttpHandler
        attr_reader   :document_root
        attr_reader   :directory_index_html
        attr_reader   :icon_url
        attr_reader   :default_mime_type
        attr_reader   :highlighting
        attr_reader   :ignore_globs
        attr_reader   :reload_template_changes
        attr_reader   :template
        attr_reader   :template_mtime
        attr_accessor :listener
        attr_reader   :request_notify

        # if any other mime types are needed, add them directly via the
        # mime-types calls.
        ADDITIONAL_MIME_TYPES = [
            # [ content-type , [ array, of, filename, extentions] ]
            ["images/svg+xml", ["svg"]],
            ["video/x-flv", ["flv"]],
            ["application/x-shockwave-flash", ["swf"]],
            ["text/plain", ["rb", "rhtml"]],
        ]

        ICONS_BY_MIME_TYPE = {
            "text/plain"                => "page_white_text.png",
            "image"                     => "picture.png",
            "pdf"                       => "page_white_acrobat.png",
            "xml"                       => "page_white_code.png",
            "compress"                  => "compress.png",
            "gzip"                      => "compress.png",
            "zip"                       => "compress.png",
            "application/xhtml+xml"     => "xhtml.png",
            "application/word"          => "page_word.png",
            "application/excel"         => "page_excel.png",
            "application/powerpoint"    => "page_white_powerpoint.png",
            "text/html"                 => "html.png",
            "application"               => "application.png",
            "text"                      => "page_white_text.png",
            :directory                  => "folder.png",
            :default                    => "page_white.png",
        }

        def initialize(options = {})
            @ignore_globs               = options[:ignore_globs] || %w( *~ .htaccess . )
            @document_root              = options[:document_root] || Dir.pwd
            @directory_listing_allowed  = options[:directory_listing_allowed] || true
            @directory_index_html       = options[:directory_index_html] || "index.html"
            @using_icons                = options[:using_icons] || true
            @icon_url                   = options[:icon_url] || "/icons"
            @reload_template_changes    = options[:reload_template_changes] || false
            @highlighting               = options[:highlighting] || false
            reload_template

            ADDITIONAL_MIME_TYPES.each do |mt|
                if MIME::Types[mt.first].size == 0 then
                    type = MIME::Type.from_array(mt)
                    MIME::Types.add(type)
                else
                    type = MIME::Types[mt.first].first
                    mt[1].each do |ext|
                        type.extensions << ext unless type.extensions.include?(ext)
                    end
                    # have to reindex if new extensions added
                    MIME::Types.index_extensions(type)
                end
            end

            @default_mime_type = MIME::Types["application/octet-stream"].first
        end

        def directory_listing_allowed?
            return !!@directory_listing_allowed
        end

        def using_icons?
            return !!@using_icons
        end

        def icon_for(mime_type)
            icon = nil
            [:content_type, :sub_type, :media_type].each do |t| 
                icon = ICONS_BY_MIME_TYPE[mime_type.send(t)]
                return icon if icon
            end
            icon = ICONS_BY_MIME_TYPE[:default]
        end

        def reload_template_changes?
            return @reload_template_changes
        end

        def reload_template
            fname = File.join(APP_RESOURCE_DIR,"listing.rhtml")
            fstat = File.stat(fname)
            @template_mtime ||= fstat.mtime
            if @template.nil? or fstat.mtime > @template_mtime then
                @template = ::ERB.new(File.read(fname))
            end
        end

        # determine how to respond to the request, it will either be a
        # directory listing, a file return, or an error return.
        def how_to_respond(req_path,query_params = {})
            return 403 unless req_path.index(document_root) == 0
            begin
                stat = File.stat(req_path)

                # if it is a directory, we either return the
                # directory index file, or a directory listing
                if stat.directory? then
                   dir_index = File.join(req_path,directory_index_html)
                   if File.exists?(dir_index) then
                       return dir_index
                   elsif directory_listing_allowed?
                       return :directory_listing
                   end

                # if it is a file and readable, make sure that the
                # path is a legal path
                elsif stat.file? and stat.readable? then
                    if should_ignore?(File.basename(req_path)) then
                        return 403
                    elsif highlighting and not %w(false off).include? query_params['highlighting'].to_s.downcase
                        ft = ::FileType[req_path,true]
                        return :highlighted_file if ft and ft != :html
                    end
                    return req_path
                else
                    log "ERROR: #{req_path} is not a directory or a readable file"
                    return 403
                end

            rescue => error
                if error.kind_of?(Errno::ENOENT) then
                    return 404
                end
                log "ERROR: Unknown, check out the stacktrace"
                log error
                return 500
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

                entry_data.name          = entry == ".." ? "Parent Directory" : entry
                entry_data.link          = entry
                entry_data.size          = num_to_bytes(stat.size)
                entry_data.last_modified = stat.mtime.strftime("%Y-%m-%d %H:%M:%S")

                if stat.directory? then
                    entry_data.content_type = "Directory"
                    entry_data.size         = "-"
                    entry_data.name         += "/"
                    if using_icons? then
                        entry_data.icon_url = File.join(icon_url, ICONS_BY_MIME_TYPE[:directory])
                    end
                else
                    entry_data.mime_type = MIME::Types.of(entry).first || default_mime_type
                    entry_data.content_type = entry_data.mime_type.content_type
                    if using_icons? then
                        entry_data.icon_url = File.join(icon_url, icon_for(entry_data.mime_type))
                    end
                end
                entries << entry_data
            end

            entries = entries.sort_by { |e| e.link }
            res_bytes = 0
            response.start(200) do |head,out|
                head['Content-Type'] = 'text/html'
                res_bytes = out.write(template.result(binding))
            end
            return res_bytes
        end

        
        # send the file back with the appropriate mimetype
        def respond_with_send_file(path,method,request,response)
            stat    = File.stat(path)
            header  = response.header
            
            header[::Mongrel::Const::LAST_MODIFIED] = stat.mtime
            header[::Mongrel::Const::CONTENT_TYPE]  = (MIME::Types.of(path).first || default_mime_type).to_s
            
            response.status = 200
            response.send_status(stat.size)
            response.send_header
            
            if method == ::Mongrel::Const::GET then
                response.send_file(path,stat.size < ::Mongrel::Const::CHUNK_SIZE * 2)
            end
            
            return stat.size
        end
        
        #
        # send back the file marked up by code ray
        def respond_with_highlighted_file(path,request,response)
            res_bytes = 0
            response.start(200) do |head,out|
                head[::Mongrel::Const::CONTENT_TYPE] = 'text/html'
                bytes = CodeRay.scan_file(path,:auto).html
                res_bytes = out.write(<<-EOM)
                <html>
                  <head>
                    <title>#{path}</title>
                    <!-- CodeRay syntax highlighting CSS -->
                    <link rel="stylesheet" href="/css/coderay-cycnus.css" type="text/css" />
                  </head>
                  <body>
                    <div class="CodeRay">
                    <pre>
#{CodeRay.scan_file(path,:auto).html({:line_numbers => :inline})}
                     </pre>
                    </div>
                  </body>
                </html>
                EOM
            end
            return res_bytes
        end

        # process the request, returning either the file, a directory
        # listing (if allowed) or an appropriate error
        def process(request, response)
            method   = request.params[Mongrel::Const::REQUEST_METHOD] || Mongrel::Const::GET
            if ( method == Mongrel::Const::GET ) or ( method == Mongrel::Const::HEAD ) then

                reload_template if reload_template_changes
                
                req_path = File.expand_path(File.join(@document_root,
                                                      ::Mongrel::HttpRequest.unescape(request.params[Mongrel::Const::PATH_INFO])),
                                            @document_root)
                res_type = how_to_respond(req_path,::Mongrel::HttpRequest.query_parse(request.params['QUERY_STRING']))
                res_size = 0
                case res_type 
                when :directory_listing
                    res_size = respond_with_directory_listing(req_path,request,response)
                when :highlighted_file
                    res_size = respond_with_highlighted_file(req_path,request,response)
                when String
                    res_size = respond_with_send_file(res_type,method,request,response)
                when Integer
                    response.status = res_type
                end
                

            # invalid method
            else
                response.start(403) { |head,out| out.write("Only HEAD and GET requests are honored.") }
            end
            log_line = [ request.params[Mongrel::Const::REMOTE_ADDR], "-", "-", "[#{Time.now.strftime("%d/%b/%Y:%H:%M:%S %Z")}]" ]
            log_line << "\"#{method}"
            log_line << request.params['REQUEST_URI']
            log_line << "#{request.params['HTTP_VERSION']}\""
            log_line << response.status
            log_line << res_size
            
            log log_line.join(' ')            
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

        def log(msg)
            STDERR.print msg, "\n"
        end
    end
end
