#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license.  See LICENSE for details
#++

require 'heel'
require 'rack'
require 'erb'
require 'tasks/config'

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
        @homepage ||= ::Configuration.for("project").homepage
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

    def process(request,response)
      status = response.status
      if status != 200 then 
        message = ::Mongrel::HTTP_STATUS_CODES[status]
        base_uri = ::Mongrel::HttpRequest.unescape(request.params[Mongrel::Const::REQUEST_URI])

        response.start(status) do |head,out|
          head['Content-Type'] = 'text/html'
          out.write(template.result(binding))
        end
      end
    end
  end
end
