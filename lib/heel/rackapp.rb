# frozen_string_literal: true

#--
# Copyright (c) 2007 - 2013 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license. See LICENSE for details
#++

require "rack"
require "rack/utils"
require "rouge"
require "time"

module Heel
  # Internal: The Rack application that is Heel.
  #
  class RackApp
    attr_reader :document_root, :directory_index_html, :icon_url, :ignore_globs, :options

    def initialize(options = {})
      @ignore_globs               = options[:ignore_globs] ||= %w[*~ .htaccess .]
      @document_root              = options[:document_root] ||= Dir.pwd
      @directory_listing_allowed  = options[:directory_listing_allowed] ||= true
      @directory_index_html       = options[:directory_index_html] ||= "index.html"
      @using_icons                = options[:using_icons] ||= true
      @icon_url                   = options[:icon_url] ||= "/heel_icons"
      @highlighting               = options[:highlighting] ||= false
      @options                    = options
    end

    def directory_listing_allowed?
      @directory_listing_allowed
    end

    def highlighting?
      @highlighting
    end

    def should_ignore?(fname)
      ignore_globs.each do |glob|
        return true if ::File.fnmatch(glob, fname)
      end
      false
    end

    # formulate a directory index response
    #
    def directory_index_response(req)
      dir_index = File.join(req.request_path, directory_index_html)

      return ResourceResponse.new(request: req, path: dir_index, options:).finish if File.readable?(dir_index)
      return DirectoryIndexResponse.new(request: req, options:).finish if directory_listing_allowed?

      return ::Heel::ErrorResponse.new(request: req, message: "Directory index is forbidden", status: 403).finish
    end

    # formulate a file content response. Possibly a rouge highlighted file if
    # it is a type that rouge can deal with and the file is not already an
    # html file.
    #
    def file_response(request)
      ResourceResponse.new(request:, options:).finish
    end

    # interface to rack, env is a hash
    #
    # returns [ status, headers, body ]
    #
    def call(env)
      req = Heel::Request.new(env, document_root)

      if req.get?
        if req.forbidden? || should_ignore?(req.request_path)
          return ErrorResponse.new(request: req,
                                   message: "You do not have permissionto view #{req.path_info}",
                                   status: 403).finish
        end

        return ErrorResponse.new(request: req,
                                 message: "File not found: #{req.path_info}",
                                 status: 404).finish unless req.found?

        return directory_index_response(req) if req.for_directory?

        return file_response(req) if req.for_file?

        ErrorResponse.new(request: req,
                          message: "Request for #{req.path_info} is not a file or directory",
                          status: 404).finish
      else
        ErrorResponse.new(request: req,
                          message: "Method #{req.request_method} Not Allowed. Only GET is honored.",
                          status: 405,
                          headers: { "Allow" => "GET" },
                         ).finish
      end
    end
  end
end
