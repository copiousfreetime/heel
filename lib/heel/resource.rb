# frozen_string_literal: true

#--
# Copyright (c) 2007 - 2013 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license. See LICENSE for details
#++

module Heel
  # Internal: Resource representing a single file or directory that is being served
  #
  class Resource
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

    def web_content?
      MimeUtils.web_content?(magic)
    end

    def text?
      magic&.text?
    end

    def icon_slug
      key = directory? ? :directory : magic
      MimeUtils.icon_for(key)
    end

    def content_type
      directory? ? "Directory" : (magic&.type&.downcase || "application/octet-stream")
    end

    def lexer(source = File.read(path, 8192))
      ::Rouge::Lexer.guess(
        filename: path,
        source: source,
        mime_type: content_type
      )
    end

    def highlightable?
      lexer && !MimeUtils.web_content?(magic)
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
