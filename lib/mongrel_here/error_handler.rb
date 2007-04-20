require 'erb'

module MongrelHere

    class ErrorHandler < Mongrel::HttpHandler

        attr_reader :template

        def initialize(options = {})
            @template = ::ERB.new File.read(File.join(APP_DATA_DIR,"error.rhtml"))
        end

        def process(request,response)
            status = response.status
            if status != 200 then 
                message = ::Mongrel::HTTP_STATUS_CODES[status]

                response.start(status) do |head,out|
                    head['Content-Type'] = 'text/html'
                    out.write(template.result(binding))
                end
            end
        end
    end
end
