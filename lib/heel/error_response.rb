#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license.  See LICENSE for details
#++

require 'heel'
require 'rack'
require 'erb'

module Heel

  class ErrorResponse < ::Rack::Response

    attr_reader :base_uri

    class << self
      def template_file
        @template_file ||= Heel::Configuration.data_path("error.rhtml")
      end

      def template
        @template ||= ::ERB.new(File.read(template_file))
      end

      def homepage
        @homepage ||= Heel::Configuration::HOMEPAGE
      end
    end

    def initialize(base_uri, body, status = 404, header = {})
      super(body, status, header)
      self['Content-type'] = 'text/html'
      @base_uri = base_uri
    end

    def finish
      message  = ::Rack::Utils::HTTP_STATUS_CODES[status]
      homepage = ErrorResponse.homepage

      return [ status, header.to_hash, ErrorResponse.template.result(binding) ]
    end
  end
end
