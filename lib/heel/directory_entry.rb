# frozen_string_literal: true

module Heel
  DirectoryEntry = Struct.new(:name, :link, :last_modified, :content_type,
                              :display_size, :icon_url, :mime_type,
                              keyword_init: true)
end
