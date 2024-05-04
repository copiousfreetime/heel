# frozen_string_literal: true

require 'ostruct'
module Heel
  # Internal: Container for variables being sent to a template
  #
  class TemplateVars < OpenStruct
    def binding_for_template
      return binding
    end

    def highlighting?
      self.highlighting
    end
  end
end
