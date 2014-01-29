module FiatLux
  module Graphics
    module Rendering
      module OpenGL
        module Shader
          module Vertex

            class Program

              attr_reader :handle

              def initialize(opts = {})
                @source = opts.fetch(:source).to_s
                @driver = opts.fetch(:driver)
                create_shader_program
              end

              def shader_type
                :vertex_shader
              end

              private

              def create_shader_program
                program_handle = @driver.create_shader_program(shader_type,@source)
                if program_handle > 0
                  @handle = program_handle
                else
                  # program_info_log = @driver.get_program_info_log(program_handle)
                  fail log_status(program_handle)
                end
              end

              def log_status(program)
                is_ppo = glIsProgramPipelineEXT(program) == GL_TRUE
                if is_ppo
                  length = Pointer.new(:int).tap do |ptr|
                    glGetProgramPipelineivEXT(program, GL_INFO_LOG_LENGTH,ptr)
                  end.value
                  messages_ptr = Pointer.new(:char,length)
                  glGetProgramPipelineInfoLogEXT(program,length,nil,messages_ptr)
                  (0...length).map{ |idx| messages_ptr[idx] }.pack('c*')
                else
                  length = Pointer.new(:int).tap do |ptr|
                    glGetProgramiv(program, GL_INFO_LOG_LENGTH,ptr)
                  end.value
                  messages_ptr = Pointer.new(:char,length)
                  glGetProgramInfoLog(program,length,nil,messages_ptr)
                  (0...length).map{ |idx| messages_ptr[idx] }.pack('c*')
                end
              end

            end

          end
        end
      end
    end
  end
end