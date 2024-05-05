# frozen_string_literal: true

module Heel
  # Internal: A wrapper for a rack response
  #
  class Response
    attr_reader :request, :options, :response

    def self.homepage
      @homepage ||= Heel::Configuration::HOMEPAGE
    end

    def self.default_headers
      {
        "Cache-Control" => "no-cache, no-store, max-age=0, private, must-revalidate",
        "Content-Type" => "text/html"
      }
    end

    # Initialize the request with the environment and the root directory of the
    # request
    def initialize(request:, options: {}, status: 200, headers: Response.default_headers)
      @request = request
      @options = options
      @response = Rack::Response.new("", status, headers)
    end

    def should_ignore?(fname)
      options[:ignore_globs].each do |glob|
        return true if ::File.fnmatch(glob, fname)
      end
      false
    end

    def base_uri
      request.base_uri
    end

    def request_path
      request.request_path
    end

    def highlighting?
      options.fetch(:highlighting, false)
    end

    def using_icons?
      options.fetch(:using_icons, false)
    end

    def icon_base_url
      options.fetch(:icon_url, "/heel_icons")
    end

    def homepage
      self.class.homepage
    end
  end
end
