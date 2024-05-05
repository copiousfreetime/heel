# frozen_string_literal: true

#--
# Copyright (c) 2007 - 2013 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license. See LICENSE for details
#++

require "marcel"

module Heel
  # Internal: Generate a resource response.
  #
  # This may be highlighted or it may just be a raw response
  #
  class ResourceResponse < Response
    attr_reader :path, :resource

    def initialize(request:, path: nil, status: 200, headers: {}, options: {})
      super(request: request, options: options, status: status, headers: headers)
      @path = path || request_path
      @resource = Resource.new(path: @path)
    end

    def content_type_of_path
      content_type = resource.content_type

      # if we could parse it, and its octet-stream -- then send it as text/plain
      return "text/plain" if content_type == "application/octet-stream" && resource.lexer

      # if its html/javascript/css return it
      return content_type if resource.web_content?

      # and then textish if its text-like
      return "text/plain" if resource.text?

      # and finally - what it is
      content_type
    end

    def highlighted_body
      source = File.read(path)
      lexer = resource.lexer(source)
      formatter = ::Rouge::Formatters::HTMLPygments.new(::Rouge::Formatters::HTML.new)
      content = formatter.format(lexer.lex(source))

      <<-BODY
      <html>
        <head>
          <title>#{request.path_info}</title>
          <link href='/__heel__/css/syntax-highlighting.css' rel='stylesheet' type='text/css'>
        </head>
        <body>
          #{content}
        </body>
      </html>
      BODY
    end

    def build_highlighted_response
      response["Content-Type"] = "text/html"
      response.write(highlighted_body)
    end

    def build_content_response
      response["Content-Type"] = content_type_of_path
      resource.with_io do |io|
        while (p = io.read(8192))
          response.write(p)
        end
      end
    end

    # generate the directory index html page of a directory
    #
    def finish
      response["Last-Modified"] = request.stat.mtime.rfc822

      if highlighting? && request.highlighting_allowed? && resource.highlightable?
        build_highlighted_response
      else
        build_content_response
      end

      response.finish
    end
  end
end
