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

            def add_binding(opts = {})
              program  = opts.fetch(:program)
              variable = opts.fetch(:variable)
              name     = opts.fetch(:name)
              size     = variable.component_size
              gl_type  = case variable.type
              when :float
                GL_FLOAT
              end
              data = variable.data.flatten
              vertices_ptr  = Pointer.new(variable.type, data.count)
              data.each_with_index { |e,index| vertices_ptr[index] = e }
              index = glGetAttribLocation(program.handle, name)
              glVertexAttribPointer(index,size,gl_type,GL_FALSE,0,vertices_ptr)
              glEnableVertexAttribArray(index)
            end

            private
            attr_reader :driver
          end

        end
      end
    end
  end
end