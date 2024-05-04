#--
# Copyright (c) 2007 - 2013 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license. See LICENSE for details
#++

require 'rack'
require 'rack/utils'
require 'rouge'
require 'time'

module Heel
  # Internal: The Rack application that is Heel.
  #
  class RackApp
    attr_reader :document_root, :directory_index_html, :icon_url, :highlighting, :ignore_globs

    def initialize(options = {})
      @ignore_globs               = options[:ignore_globs] ||= %w(*~ .htaccess .)
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
      @directory_indexer ||= DirectoryIndexer.new(directory_index_template_file, @options)
    end

    def should_ignore?(fname)
      ignore_globs.each do |glob|
        return true if ::File.fnmatch(glob, fname)
      end
      false
    end

    # formulate a directory index response
    #
    def directory_index_response(req)
      response = ::Rack::Response.new
      dir_index = File.join(req.request_path, directory_index_html)
      if File.file?(dir_index) && File.readable?(dir_index) then
        response['Content-Type'] = mime_map.mime_type_of(dir_index).to_s
        response.write(File.read(dir_index))
      elsif directory_listing_allowed? then
        body                       = directory_indexer.index_page_for(req)
        response['Content-Type']   = 'text/html'
        response.write(body)
      else
        return ::Heel::ErrorResponse.new(req.path_info, "Directory index is forbidden", 403).finish
      end
      return response.finish
    end

    def slurp_path(path)
      source = nil
      File.open(path, 'rt:bom|utf-8') do |f|
        source = f.read
      end
      return source
    end

    def highlight_contents(req, file_type)
      source = slurp_path(req.request_path)
      # only do a rouge type check if we are going to use rouge in the
      # response
      lexer = ::Rouge::Lexer.guess(
        filename: req.request_path,
        source: source,
        mime_type: file_type
      )

      formatter = ::Rouge::Formatters::HTMLPygments.new(::Rouge::Formatters::HTML.new)
      content = formatter.format(lexer.lex(source))

      body = <<-BODY
      <html>
        <head>
          <title>#{req.path_info}</title>
          <link href='/heel_css/syntax-highlighting.css' rel='stylesheet' type='text/css'>
        </head>
        <body>
          #{content}
        </body>
      </html>
      BODY

      return body
    end

    # formulate a file content response. Possibly a rouge highlighted file if
    # it is a type that rouge can deal with and the file is not already an
    # html file.
    #
    def file_response(req)
      response = ::Rack::Response.new
      response['Last-Modified'] = req.stat.mtime.rfc822
      file_type = mime_map.mime_type_of(req.request_path)

      if highlighting? && req.highlighting? then
        if file_type && (file_type != 'text/html') then
          body = highlight_contents(req, file_type)
          response['Content-Type']   = 'text/html'
          response['Content-Length'] = body.length.to_s
          response.write(body)
          return response.finish
        end
      end

      # fall through to a default file return
      response['Content-Type'] = file_type.to_s
      File.open(req.request_path) do |f|
        while (p = f.read(8192)) do
          response.write(p)
        end
      end
      return response.finish
    end

    # interface to rack, env is a hash
    #
    # returns [ status, headers, body ]
    #
    def call(env)
      req = Heel::Request.new(env, document_root)
      if req.get? then
        if req.forbidden? || should_ignore?(req.request_path) then
          return ErrorResponse.new(req.path_info, "You do not have permissionto view #{req.path_info}", 403).finish
        end
        return ErrorResponse.new(req.path_info, "File not found: #{req.path_info}", 404).finish unless req.found?
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
