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
      super(request:, options:, status:, headers:)
      @path = path || request_path
      @resource = Resource.new(path: @path)
    end

    def content_type_of_path
      content_type = resource.content_type
      if content_type == "application/octet-stream"
        # fall through to the default file, type, but - if we 'could' parse it
        # and it is of type application/octet-stream, then we should subvert it to
        # text/plain
        chunk = File.read(path, 8192)
        lexer = rouge_lexer_for(path, chunk, content_type)
        return "text/plain" if lexer
      elsif resource.text?
        return "text/plain"
      end

      content_type
    end

    def rouge_lexer_for(filename, source, mime_type)
      ::Rouge::Lexer.guess(
        filename: filename,
        source: source,
        mime_type: mime_type
      )
    end

    def highlighted_body
      source = File.read(path)
      lexer = rouge_lexer_for(path, source, resource.content_type)
      formatter = ::Rouge::Formatters::HTMLPygments.new(::Rouge::Formatters::HTML.new)
      content = formatter.format(lexer.lex(source))

      <<-BODY
      <html>
        <head>
          <title>#{request.path_info}</title>
          <link href='/heel_css/syntax-highlighting.css' rel='stylesheet' type='text/css'>
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

      if highlighting? && request.highlighting_allowed? && resource.text?
        build_highlighted_response
      else
        build_content_response
      end

      response.finish
    end
  end
end
