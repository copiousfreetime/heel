require 'heel'
require 'erb'

module Heel

    class ErrorHandler < ::Mongrel::HttpHandler

        attr_reader     :template
        attr_accessor   :listener
        attr_reader     :request_notify
        

        def initialize(options = {})
            @template = ::ERB.new File.read(File.join(APP_DATA_DIR,"error.rhtml"))
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
