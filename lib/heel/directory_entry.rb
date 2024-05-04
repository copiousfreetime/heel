# frozen_string_literal: true

module Heel
  # Internal: Strure for holding display information on a directory entry
  #
  class DirectoryEntry
    attr_reader :entry, :parent_path, :path, :stat, :icon_base_url

    def initialize(parent_path:, entry:, using_icons: false, icon_base_url: nil)
      @parent_path = parent_path
      @entry = entry
      @path = File.join(parent_path, entry)
      @stat = File.stat(@path)
      @using_icons = using_icons
      @icon_base_url = icon_base_url
    end

    def name
      name = dotdot? ? "Parent Directory" : entry
      name += "/" if stat.directory?
      name
    end

    def last_modified
      stat.mtime.strftime("%Y-%m-%d %H:%M:%S")
    end

    def display_size
      return "-" if stat.directory?

      num_to_bytes(stat.size)
    end

    def link
      ERB::Util.url_encode(entry)
    end

    def mime_type
      MimeMap.mime_type_of(entry)
    end

    def content_type
      stat.directory? ? "Directory" : mime_type.content_type
    end

    def icon_url
      return nil unless using_icons?
      return nil unless icon_base_url

      slug = stat.directory? ? MimeMap.icons_by_mime_type[:directory] : mime_type.to_s

      File.join(icon_base_url, slug)
    end

    private

    # essentially this is strfbytes from facets
    #
    def num_to_bytes(num, fmt = "%.2f")
      return "#{num} bytes" if num < 1024
      return "#{fmt % (num.to_f / 1024)} KB" if num < (1024**2)
      return "#{fmt % (num.to_f / (1024**2))} MB" if num < (1024**3)
      return "#{fmt % (num.to_f / (1024**3))} GB" if num < (1024**4)
      return "#{fmt % (num.to_f / (1024**4))} TB" if num < (1024**4)

      "#{fmt % (num.to_f / (1024**5))} PB"
    end

    def dotdot?
      entry == ".."
    end

    def using_icons?
      @using_icons
    end
  end
end
