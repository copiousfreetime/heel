require 'ostruct'
module Heel
  class TemplateVars < OpenStruct
    def binding_for_template()
      return binding()
    end
  end
end
