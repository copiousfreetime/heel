# frozen_string_literal: true

#--
# Copyright (c) 2007 - 2013 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license. See LICENSE for details
#++

require "erb"
require_relative "response"
require_relative "directory_entry"
require_relative "directory_listing_vars"
require_relative "template"

module Heel
  # Internal: Generate a directory index
  #
  class DirectoryIndexResponse < Response
    def self.directory_index_template_file
      @directory_index_template_file ||= Heel::Configuration.data_path("listing.rhtml")
    end

    def self.template
      @template ||= Template.new(directory_index_template_file)
    end

    def entries
      [].tap do |entries|
        Dir.entries(request_path).each do |raw_entry|
          next if should_ignore?(raw_entry)

          entry_data = DirectoryEntry.new(parent_path: request_path,
                                          entry: raw_entry,
                                          using_icons: using_icons?,
                                          icon_base_url: icon_base_url,
                                         )

          next if (request_path == options[:document_root]) && entry_data.dotdot?

          entries << entry_data
        end
      end
    end

    # generate the directory index html page of a directory
    #
    def finish
      template_vars = DirectoryListingVars.new(base_uri: base_uri,
                                               highlighting: highlighting?,
                                               directory_entries: entries.sort_by(&:link),
                                               homepage: homepage,)
      body = self.class.template.render(template_vars.binding_for_template)
      response.write(body)
      response.finish
    end
  end
end
