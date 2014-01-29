module FiatLux
  module Graphics
    module Rendering
      module OpenGL

        class Context
          attr_reader :eagl_context
          def initialize(eagl_context)
            @eagl_context = eagl_context
          end
          def api_version
            @eagl_context.API
          end
        end

      end
    end
  end
end