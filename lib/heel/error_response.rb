#--
# Copyright (c) 2007 - 2013 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license. See LICENSE for details
#++

require 'rack'
require 'erb'

module Heel

  class ErrorResponse

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
      header    = header.merge( "Content-Type" => 'text/html' )
      @response = Rack::Response.new('', status, header )
      @base_uri = base_uri
    end

    def finish
      template_vars = TemplateVars.new( :status   => @response.status,
                                        :message  => Rack::Utils::HTTP_STATUS_CODES[@response.status],
                                        :base_uri => base_uri,
                                        :homepage => ErrorResponse.homepage )

      content  = ErrorResponse.template.result( template_vars.binding_for_template )
      @response.write( content )
      return @response.finish
    end
  end
end
