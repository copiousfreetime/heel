# frozen_string_literal: true

#--
# Copyright (c) 2007 - 2013 Jeremy Hinegardner
# All rights reserved. Licensed under the BSD license. See LICENSE for details
#++

require "rack"
require "erb"

module Heel
  # Internal: Wrapper for the http error code responses
  #
  class ErrorResponse < Response
    def self.error_template_file
      @error_template_file ||= Heel::Configuration.data_path("error.rhtml")
    end

    def self.template
      @template ||= Template.new(error_template_file)
    end

    attr_reader :message

    def initialize(request:, message: nil, status: 404, headers: {}, options: {})
      super(request: request, options: options, status: status, headers: headers)
      @message = message
    end

    def finish
      status = response.status

      template_vars = ErrorResponseVars.new(
        status: status,
        message: message || Rack::Utils::HTTP_STATUS_CODES[status],
        base_uri: base_uri,
        homepage: homepage
      )

      body = self.class.template.render(template_vars.binding_for_template)
      response.write(body)
      response.finish
    end
  end
end
