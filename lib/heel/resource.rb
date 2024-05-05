# frozen_string_literal: true

#--
# Copyright (c) 2007 - 2013 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license. See LICENSE for details
#++

require "marcel"

module Heel
  # Internal: Resource representing a single file or directory that is being served
  #
  class Resource
    class << self
      def icons_by_content_type
        @icons_by_content_type ||= Hash.new("file.svg").tap do |hash|
          hash.update({
                        "image" => "image.svg",
                        "pdf" => "pdf.svg",
                        "x-zip-compressed" => "zip.svg",
                        "x-gtar" => "zip.svg",
                        "x-gzip" => "zip.svg",
                        "application/x-word" => "word.svg",
                        "application/powerpoint" => "presentation.svg",
                        "text/html" => "html5.svg",
                        :directory => "folder-alt.svg",
                      })
        end
      end
    end

    attr_reader :path, :magic, :stat

    def initialize(path:)
      @path = path
      @stat = File.stat(@path)
      @magic = calculate_magic(@path) unless directory?
    end

    def last_modified
      stat.mtime.strftime("%Y-%m-%d %H:%M:%S")
    end

    def size
      stat.size
    end

    def directory?
      stat.directory?
    end

    def icon_slug
      key = directory? ? :directory : content_type
      self.class.icons_by_mime_type[key]
    end

    def content_type
      directory? ? "Directory" : (magic&.type&.downcase || "application/octet-stream")
    end

    def text?
      magic&.text?
    end

    def lexer(source = File.read(path, 8192))
      ::Rouge::Lexer.guess(
        filename: path,
        source: source,
        mime_type: content_type
      )
    end

    def highlightable?
      lexer && !web_content?
    end

    def web_content?
      %w[text/html text/css text/javascript].include?(content_type)
    end

    def calculate_magic(path)
      magic = nil
      with_io(path) do |io|
        magic = Marcel::Magic.by_magic(io)
      end
      magic ||= Marcel::Magic.by_path(path)
    end

    def with_io(path = @path, &block)
      File.open(path, "rt:bom|utf-8", &block)
    end
  end
end
