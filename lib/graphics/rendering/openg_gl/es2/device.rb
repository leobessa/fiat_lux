module FiatLux
  module Graphics
    module Rendering
      module OpenGL
        module ES2

          class Device

            def initialize(opts={})
              @context = opts.fetch(:context){ GL::ContextFactory.new.create(api_version: 2) }
              @driver  = opts.fetch(:driver){ GL::ES2::Driver.new }
            end

            def create_vertex_shader(opts = {})
              source = opts.fetch(:source).to_s
              FiatLux::Graphics::Rendering::OpenGL::Shader::Vertex::Program.new(source: source, driver: driver)
            end

            def create_fragment_shader(opts = {})
              source = opts.fetch(:source).to_s
              FiatLux::Graphics::Rendering::OpenGL::Shader::Fragment::Program.new(source: source, driver: driver)
            end

            def create_pipeline_program(opts = {})
              vertex_shader = opts.fetch(:vertex_shader)
              fragment_shader = opts.fetch(:fragment_shader)
              FiatLux::Graphics::Rendering::OpenGL::Pipeline::Program.new(vertex_shader: vertex_shader, fragment_shader: fragment_shader, driver: driver)
            end

            def program_pipeline=(program)
              @driver.bind_program_pipeline(program.handle)
            end

            def create_geometry
              FiatLux::Graphics::Rendering::Geometry.new
            end

            private
            attr_reader :driver
          end

        end
      end
    end
  end
end