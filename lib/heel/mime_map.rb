# frozen_string_literal: true

#--
# Copyright (c) 2007 - 2013 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license. See LICENSE for details
#++

require "marcel"

Marcel::MimeType.extend "text/markdown", extensions: %w[rdoc], parents: "text/x-web-markdown"

module Heel
  # Internal: MimeMap is a Heel specific mime mapping utility.
  #
  #
  class MimeMap
    class << self
      def icons_by_mime_type
        @icons_by_mime_type ||= {
          "text/plain" => "file.svg",
          "image" => "image.svg",
          "pdf" => "pdf.svg",
          "x-zip-compressed" => "zip.svg",
          "x-gtar" => "zip.svg",
          "x-gzip" => "zip.svg",
          "application/x-word" => "word.svg",
          "application/powerpoint" => "presentation.svg",
          "text/html" => "html5.svg",
          "application" => "file.svg",
          "text" => "file.svg",
          :directory => "folder-alt.svg",
          :default => "file.svg",
        }
      end

      # return the icon name for a particular mime type
      #
      def icon_for(content_type)
        MimeMap.icons_by_mime_type.fetch(content_type) { MimeMap.icons_by_mime_type[:default] }
      end

      # returns the mime type of the file at a given pathname
      #
      def mime_type_of(filename)
        path = Pathname.new(filename) if File.exist?(filename)
        Marcel::MimeType.for(path, name: filename)
      end
    end
  end
end
