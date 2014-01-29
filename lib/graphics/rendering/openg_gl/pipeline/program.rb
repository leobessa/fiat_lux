module FiatLux
  module Graphics
    module Rendering
      module OpenGL
        module Pipeline

          class Program

            def initialize(opts = {})
              @driver          = opts.fetch(:driver)
              @vertex_shader   = opts.fetch(:vertex_shader)
              @fragment_shader = opts.fetch(:fragment_shader)
              # TODO: Assert shaders are compiled
              link!
            end

            private

            def link!
              handle = @driver.gen_program_pipeline
              @driver.bind_program_pipeline(handle)
              @driver.use_program_stages(handle, :vertex_shader_bit_ext, @vertex_shader.handle)
              @driver.use_program_stages(handle, :fragment_shader_bit_ext, @fragment_shader.handle)
              true
            end

          end

        end
      end
    end
  end
end