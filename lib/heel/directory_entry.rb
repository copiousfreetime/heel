# frozen_string_literal: true

module Heel
  # Internal: Strure for holding display information on a directory entry
  #
  class DirectoryEntry
    attr_reader :entry, :parent_path, :path, :stat, :icon_base_url, :resource

    def initialize(parent_path:, entry:, using_icons: false, icon_base_url: nil)
      @parent_path = parent_path
      @entry = entry
      @path = File.join(parent_path, entry)
      @resource = Resource.new(path: @path)
      @using_icons = using_icons
      @icon_base_url = icon_base_url
    end

    def name
      name = dotdot? ? "Parent Directory" : entry
      name += "/" if directory?
      name
    end

    def display_size
      return "-" if directory?

      num_to_bytes(resource.size)
    end

    def last_modified
      resource.last_modified
    end

    def directory?
      resource.directory?
    end

    def link
      ERB::Util.url_encode(entry)
    end

    def content_type
      resource.content_type
    end

    def icon_url
      return nil unless using_icons?
      return nil unless icon_base_url

      File.join(icon_base_url, resource.icon_slug)
    end

    # essentially this is strfbytes from facets
    #
    def num_to_bytes(num, fmt = "%.2f")
      return "#{num} bytes" if num < 1024
      return "#{fmt % (num.to_f / 1024)} KB" if num < (1024**2)
      return "#{fmt % (num.to_f / (1024**2))} MB" if num < (1024**3)
      return "#{fmt % (num.to_f / (1024**3))} GB" if num < (1024**4)
      return "#{fmt % (num.to_f / (1024**4))} TB" if num < (1024**5)

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
