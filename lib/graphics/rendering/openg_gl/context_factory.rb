module FiatLux
  module Graphics
    module Rendering
      module OpenGL

        class ContextFactory

          EAGL_RENDERING_API_MAP = {
            3 => KEAGLRenderingAPIOpenGLES3,
            2 => KEAGLRenderingAPIOpenGLES2
          }.freeze

          class UnsupportedContextError < NotImplementedError; end

          attr_accessor :context_source

          def create(opts = {})
            version = opts.fetch(:api_version)
            eagl_context = context_source.call(version)
            unless eagl_context
              (block_given? ? yield : fail(UnsupportedContextError, "Unsupported OpenGL context for api_version: #{version}"))
            end
            Context.new(eagl_context)
          end

          def context_source
            @context_source ||= lambda { |v| EAGLContext.alloc.initWithAPI(EAGL_RENDERING_API_MAP.fetch(v.to_i)) }
          end
        end

      end
    end
  end
end