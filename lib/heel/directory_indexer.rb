# frozen_string_literal: true

#--
# Copyright (c) 2007 - 2013 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license. See LICENSE for details
#++

require "erb"

module Heel
  # Internal: Generate a directory index
  #
  class DirectoryIndexer
    attr_reader :options, :template_file, :template

    def initialize(template_file, options)
      @template         = nil
      @template_file    = template_file
      @options          = options
      reload_template
    end

    def should_ignore?(fname)
      options[:ignore_globs].each do |glob|
        return true if ::File.fnmatch(glob, fname)
      end
      false
    end

    def highlighting?
      @options.fetch(:highlighting, false)
    end

    def reload_on_template_change?
      @options.fetch(:reload_template_on_change, false)
    end

    def using_icons?
      @options.fetch(:using_icons, false)
    end

    def reload_template
      fstat = File.stat(@template_file)
      @template_mtime ||= fstat.mtime
      return unless @template.nil? || (fstat.mtime > @template_mtime)

      @template = ::ERB.new(File.read(@template_file))
    end

    # generate the directory index html page of a directory
    #
    def index_page_for(req)
      reload_template if reload_on_template_change?
      dir     = req.request_path
      entries = []
      Dir.entries(dir).each do |entry|
        next if should_ignore?(entry)
        next if (dir == @options[:document_root]) && (entry == "..")

        entry_data      = DirectoryEntry.new(parent_path: dir, entry: entry,
                                             using_icons: using_icons?, icon_base_url: options[:icon_url])
        entries << entry_data
      end

      template_vars = DirectoryListingVars.new(base_uri: req.path_info,
                                               highlighting: highlighting?,
                                               directory_entries: entries.sort_by(&:link),
                                               homepage: Heel::Configuration::HOMEPAGE)
      template.result(template_vars.binding_for_template)
    end
  end
end
