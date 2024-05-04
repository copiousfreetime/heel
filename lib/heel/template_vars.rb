# frozen_string_literal: true

require "ostruct"
module Heel
  # Internal: Container for variables being sent to a template
  #
  class TemplateVars < OpenStruct
    def binding_for_template
      binding
    end

    def highlighting?
      highlighting
    end
  end
end
