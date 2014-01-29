module FiatLux
  module Graphics
    module Rendering
      module OpenGL
        module ES2
          module Extensions
            module SeparateShaderObjectsExt
              module CreateShaderProgram
                SHADER_BIT_MAP = {
                  :vertex_shader => GL_VERTEX_SHADER,
                  :fragment_shader => GL_FRAGMENT_SHADER
                }
                module_function
                def call(type,*sources)
                  sources_list = Array(sources).flatten
                  count = sources_list.count
                  source_string_ptr = Pointer.new(:string, count)
                  sources_list.each_with_index { |s,i| source_string_ptr[i] = s }
                  glCreateShaderProgramvEXT(SHADER_BIT_MAP.fetch(type), count, source_string_ptr)
                end
              end
              module GenProgramPipeline
                module_function
                def call
                  Pointer.new(:uint).tap do |ptr|
                    glGenProgramPipelinesEXT(1,ptr)
                  end.value
                end
              end
              module BindProgramPipeline
                module_function
                def call(program_handle)
                  glBindProgramPipelineEXT(program_handle)
                end
              end
              module UseProgramStages
                SHADER_BIT_MAP = {
                  :vertex_shader_bit_ext => GL_VERTEX_SHADER_BIT_EXT,
                  :fragment_shader_bit_ext => GL_FRAGMENT_SHADER_BIT_EXT
                }
                module_function
                def call(pipeline_handle,shader_type,program_handle)
                  glUseProgramStagesEXT(pipeline_handle,SHADER_BIT_MAP.fetch(shader_type),program_handle)
                end
              end
              module Uniform1iExt
                module_function
                def call(program_handle,location,value)
                  glProgramUniform1iEXT(program_handle, location, value)
                end
              end
              module UniformMatrix4fvExt
                module_function
                TRANSPOSE_MAP = { false => GL_FALSE, true => GL_TRUE }
                def call(program_handle,location,count,transpose,value)
                  glProgramUniformMatrix4fvEXT(program_handle,location,count,TRANSPOSE_MAP.fetch(transpose),value)
                end
              end
              module Driver
                include FiatLux::Graphics::Rendering::OpenGL::Library
                attach_function :bind_program_pipeline, to: BindProgramPipeline
                attach_function :create_shader_program, to: CreateShaderProgram
                attach_function :gen_program_pipeline, to: GenProgramPipeline
                attach_function :use_program_stages, to: UseProgramStages
                attach_function :uniform1i_ext, to: Uniform1iExt
                attach_function :uniform_matrix4fv_ext, to: UniformMatrix4fvExt
              end
            end
          end
        end
      end
    end
  end
end