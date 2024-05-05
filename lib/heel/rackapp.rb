# frozen_string_literal: true

#--
# Copyright (c) 2007 - 2013 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license. See LICENSE for details
#++

require "rack"
require "rack/utils"
require "rouge"
require "time"

module Heel
  # Internal: The Rack application that is Heel.
  #
  class RackApp
    attr_reader :document_root, :directory_index_html, :icon_url, :highlighting, :ignore_globs

    def initialize(options = {})
      @ignore_globs               = options[:ignore_globs] ||= %w[*~ .htaccess .]
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
      if File.file?(dir_index) && File.readable?(dir_index)
        response["Content-Type"] = MimeMap.mime_type_of(dir_index).to_s
        response.write(File.read(dir_index))
      elsif directory_listing_allowed?
        body                       = directory_indexer.index_page_for(req)
        response["Content-Type"]   = "text/html"
        response.write(body)
      else
        return ::Heel::ErrorResponse.new(req.path_info, "Directory index is forbidden", 403).finish
      end
      response.finish
    end

    def slurp_path(path)
      source = nil
      File.open(path, "rt:bom|utf-8") do |f|
        source = f.read
      end
      source
    end

    def rouge_lexer_for(req, source, file_type)
      ::Rouge::Lexer.guess(
        filename: req.request_path,
        source: source,
        mime_type: file_type
      )
    end

    def highlight_contents(req, file_type)
      source = slurp_path(req.request_path)
      # only do a rouge type check if we are going to use rouge in the
      # response
      lexer = rouge_lexer_for(req, source, file_type)

      formatter = ::Rouge::Formatters::HTMLPygments.new(::Rouge::Formatters::HTML.new)
      content = formatter.format(lexer.lex(source))

      <<-BODY
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
    end

    # formulate a file content response. Possibly a rouge highlighted file if
    # it is a type that rouge can deal with and the file is not already an
    # html file.
    #
    def file_response(req)
      response = ::Rack::Response.new
      response["Last-Modified"] = req.stat.mtime.rfc822
      file_type = MimeMap.mime_type_of(req.request_path)

      if highlighting? && req.highlighting_allowed? && file_type
        body = highlight_contents(req, file_type)
        response["Content-Type"]   = "text/html"
        response["Content-Length"] = body.length.to_s
        response.write(body)
        return response.finish
      end

      if file_type == "application/octet-stream"
      # fall through to the default file, type, but - if we 'could' parse it
      # and it is of type application/octet-stream, then we should subvert it to
      # text/plain
        lexer = rouge_lexer_for(req, File.read(req.request_path, 4096), file_type)
        response["Content-Type"] = "text/plain" if lexer
      elsif  Marcel::Magic.child?(file_type, "text/plain")
        response["Content-Type"] = "text/plain"
      else
        response["Content-Type"] = file_type
      end

      File.open(req.request_path) do |f|
        while (p = f.read(8192))
          response.write(p)
        end
      end
      response.finish
    end

    # interface to rack, env is a hash
    #
    # returns [ status, headers, body ]
    #
    def call(env)
      req = Heel::Request.new(env, document_root)
      if req.get?
        if req.forbidden? || should_ignore?(req.request_path)
          return ErrorResponse.new(req.path_info, "You do not have permissionto view #{req.path_info}", 403).finish
        end
        return ErrorResponse.new(req.path_info, "File not found: #{req.path_info}", 404).finish unless req.found?
        return directory_index_response(req) if req.for_directory?

        file_response(req) if req.for_file?
      else
        ErrorResponse.new(req.path_info,
                          "Method #{req.request_method} Not Allowed. Only GET is honored.",
                          405,
                          { "Allow" => "GET" }).finish
      end
    end
  end
end
