module FiatLux
  module Graphics
    module Rendering
      module OpenGL
        module ES2

          class Driver
            include FiatLux::Graphics::Rendering::OpenGL::Library

            include Extensions::SeparateShaderObjectsExt::Driver

            def get_program_info_log(program_ptr,limit=nil)
              length = case limit
              when Numeric
                limit.to_i
              when NilClass
                get_program(program_ptr, :info_log_length)
              else
                fail ArgumentError, "invalid limit: #{limit}"
              end
              if length > 0
                messages_ptr = Pointer.new(:char,length)
                glGetProgramInfoLog(program_ptr,length,nil,messages_ptr)
                (0...length).map{ |idx| messages_ptr[idx] }.pack('c*')
              else
                ""
              end
            end

            PROGRAM_PARAMETER_NAME_MAP = {
              link_status: GL_LINK_STATUS,
              info_log_length: GL_INFO_LOG_LENGTH
            }
            PROGRAM_PARAMETER_MAP = {
              GL_TRUE => true, GL_FALSE => false
            }
            def get_program(program,parameter)
              parameter = Pointer.new(:int).tap do |ptr|
                glGetProgramiv(program, PROGRAM_PARAMETER_NAME_MAP.fetch(parameter),ptr)
              end.value
              # PROGRAM_PARAMETER_MAP.fetch(parameter)
            end

          end

        end
      end
    end
  end
end