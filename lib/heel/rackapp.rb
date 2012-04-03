#--
# Copyright (c) 2007, 2008 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license.  See LICENSE for details
#++

require 'heel'
require 'rack'
require 'rack/utils'
require 'coderay'
require 'coderay/helpers/file_type'
require 'time'

module Heel
  class RackApp

    attr_reader   :document_root
    attr_reader   :directory_index_html
    attr_reader   :icon_url
    attr_reader   :highlighting
    attr_reader   :ignore_globs


    def initialize(options = {})
      @ignore_globs               = options[:ignore_globs] ||= %w( *~ .htaccess . )
      @document_root              = options[:document_root] ||= Dir.pwd
      @directory_listing_allowed  = options[:directory_listing_allowed] ||= true
      @directory_index_html       = options[:directory_index_html] ||= "index.html"
      @using_icons                = options[:using_icons] ||= true
      @icon_url                   = options[:icon_url] ||= "/heel_icons"
      @highlighting               = options[:highlighting] ||= false
      @options                    = options
    end

    def directory_listing_allowed?
      @directory_listing_allowed
    end

    def highlighting?
      @highlighting
    end

    def mime_map
      @mime_map ||= Heel::MimeMap.new
    end

    def directory_index_template_file
      @directory_index_template_file ||= Heel::Configuration.data_path("listing.rhtml")
    end

    def directory_indexer
      indexer_ignore = ( ignore_globs + [ document_root] ).flatten
      @directory_indexer ||= DirectoryIndexer.new( directory_index_template_file, @options )
    end


    def should_ignore?(fname)
      ignore_globs.each do |glob|
        return true if ::File.fnmatch(glob,fname)
      end
      false 
    end

    # formulate a directory index response
    #
    def directory_index_response(req)
      response = ::Rack::Response.new
      dir_index = File.join(req.request_path, directory_index_html) 
      if File.file?(dir_index) and File.readable?(dir_index) then
        response['Content-Type']   = mime_map.mime_type_of(dir_index).to_s
        response['Content-Length'] = File.size(dir_index).to_s
        response.body              = File.open(dir_index)
      elsif directory_listing_allowed? then
        body                       = directory_indexer.index_page_for(req)
        response['Content-Type']   = 'text/html'
        response['Content-Length'] = body.length.to_s
        response.body             << body
      else
        return ::Heel::ErrorResponse.new(req.path_info,"Directory index is forbidden", 403).finish
      end
      return response.finish
    end


    # formulate a file content response. Possibly a coderay highlighted file if
    # it is a type that code ray can deal with and the file is not already an
    # html file.
    #
    def file_response(req)
      response = ::Rack::Response.new

      response['Last-Modified'] = req.stat.mtime.rfc822

      if highlighting? and req.highlighting? then 
        # only do a coderay type check if we are going to use coderay in the
        # response
        code_ray_type = CodeRay::FileType[req.request_path, true] 
        if code_ray_type and (code_ray_type != :html) then
          body = <<-EOM
          <html>
            <head>
            <title>#{req.path_info}</title>
            <!-- CodeRay syntax highlighting CSS -->
            <link rel="stylesheet" href="/heel_css/coderay-cycnus.css" type="text/css" />
            </head>
            <body>
              <div class="CodeRay">
                <pre>
  #{CodeRay.scan_file(req.request_path,:auto).html({:line_numbers => :inline})}
                </pre>
              </div>
            </body>
          </html>
          EOM
          response['Content-Type']    = 'text/html'
          response['Content-Length']  = body.length.to_s
          response.body << body
          return response.finish
        end
      end

      # fall through to a default file return

      file_type                   = mime_map.mime_type_of(req.request_path)
      response['Content-Type']    = file_type.to_s
      response['Content-Length']  = req.stat.size.to_s

      return response.finish do 
        File.open(req.request_path) do |f|
          while p = f.read(8192)
            response.write p
          end
        end
      end

    end

    # interface to rack, env is a hash
    #
    # returns [ status, headers, body ]
    #
    def call(env)
      req = Heel::Request.new(env, document_root)
      if req.get? then
        if req.forbidden? or should_ignore?(req.request_path) then
          return ErrorResponse.new(req.path_info,"You do not have permissionto view #{req.path_info}",403).finish 
        end
        return ErrorResponse.new(req.path_info, "File not found: #{req.path_info}",403).finish unless req.found?
        return directory_index_response(req)                           if req.for_directory?
        return file_response(req)                                      if req.for_file?
      else
        return ErrorResponse.new(req.path_info,
                                 "Method #{req.request_method} Not Allowed. Only GET is honored.", 
                                 405, 
                                 { "Allow" => "GET" }).finish
      end
    end
  end
end
