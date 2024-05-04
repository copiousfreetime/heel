# frozen_string_literal: true

#--
# Copyright (c) 2007 - 2013 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license. See LICENSE for details
#++

require "mime/types"

module Heel
  # Internal: MimeMap is a Heel specific mime mapping utility.
  #
  # It is based upon MIME::Type and adds some additional mime types.  It can
  # also say what the icon name for a particular mime type is.
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

      # if any other mime types are needed, add them directly via the
      # mime-types calls.
      def additional_mime_types
        [
          MIME::Type.new("text/plain") { |t| t.extensions = %w[rb rdoc rhtml md markdown] },
        ]
      end
    end

    def initialize
      MimeMap.additional_mime_types.each do |mt|
        existing_type = MIME::Types[mt]
        if existing_type.empty?
          MIME::Types.add(mt)
        else
          type = existing_type.first
          type.add_extensions(mt.extensions)
        end
      end
    end

    def default_mime_type
      @default_mime_type ||= MIME::Types["application/octet-stream"].first
    end

    # returns the mime type of the file at a given pathname
    #
    def mime_type_of(filename)
      MIME::Types.of(filename).last || default_mime_type
    end

    # return the icon name for a particular mime type
    #
    def icon_for(mime_type)
      icon = nil
      %i[content_type sub_type media_type].each do |t|
        icon = MimeMap.icons_by_mime_type[mime_type.send(t)]
        return icon if icon
      end
      icon = MimeMap.icons_by_mime_type[:default]
    end
  end
end
