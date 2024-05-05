module Heel
  # Internal: This is lookup to find the icon for a particular mime / content-type
  module MimeUtils

    DIRECTORY_ICON = "folder.svg"
    DEFAULT_ICON = "file-unknown.svg"

    WEB_CONTENT_MEDIA_TYPES = %w[ audio font image video ]
    WEB_CONTENT_TYPES = %w[
      text/html
      text/css
      text/javascript
    ]

    def web_content?(magic)
      return false if magic.nil?
      return true if WEB_CONTENT_MEDIA_TYPES.include?(magic.mediatype)
      return true if WEB_CONTENT_TYPES.include?(magic.type.downcase)
      return false
    end

    def icons_by_content_type
      @icons_by_content_type ||= {
        "application/zip" => "file-zip.svg",
        "application/x-tar" => "file-zip.svg",
        "application/gzip" => "file-zip.svg",
        "application/vnd.ms-powerpoint" => "presentation.svg",
      }
    end

    def icons_by_media_type
      @icons_by_media_type ||= {
        "application" => "file.svg",
        "audio" => "volume.svg",
        "example" => "question-mark.svg",
        "font" => "typography.svg",
        "image" => "image.svg",
        "model" => "cube.svg",
        "text" => "file-text.svg",
        "video" => "video.svg",
      }
    end

    def icon_for(key)
      return DEFAULT_ICON if key.nil?
      return DIRECTORY_ICON if key == :directory

      icons_by_content_type[key.type.downcase] ||
        icons_by_media_type[key.mediatype] ||
        DEFAULT_ICON
    end
    extend self
  end
end
