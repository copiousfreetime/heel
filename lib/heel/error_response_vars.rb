# frozen_string_literal: true

module Heel
  # Internal: Container for variables being sent to a listing template
  #
  ErrorResponseVars = Struct.new(:status, :message, :base_uri, :homepage, keyword_init: true) do
    def binding_for_template
      binding
    end
  end
end
