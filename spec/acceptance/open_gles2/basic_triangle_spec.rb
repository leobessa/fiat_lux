module FiatLux::Graphics::Rendering
  describe '' do
    it 'can generate a triangle' do
      # given a OpenGL ES 2.0 context
      context = OpenGL::ContextFactory.new.create(api_version: 2)
      # and a OpenGL ES 2.0 driver
      driver = OpenGL::ES2::Driver.new
      # when I create a OpenGL device with the context and the driver
      device = OpenGL::ES2::Device.new(context: context, driver: driver)
      EAGLContext.setCurrentContext(context.eagl_context)
      # and I create a vertex shader program
      vertex_shader = device.create_vertex_shader(source: <<-eos)
        #extension GL_EXT_separate_shader_objects : enable
        attribute vec4 vPosition;
        void main(){
          gl_Position = vPosition;
        }
      eos
      # and a fragment shader program
      fragment_shader = device.create_fragment_shader(source: <<-eos)
        precision mediump float;
        void main(){
          gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
        }
      eos
      # and create a pipeline program from them
      device.create_pipeline_program(vertex_shader: vertex_shader, fragment_shader: fragment_shader)
      # Load the OpenGL driver
      # Create the rendering device.
      
      # Compile the programs.
      # vp_source = FiatLux::Core::File.new("vertex_shaders/simple_vp.glsl")
      # vertex_program = @device.compile_vertex_program(vp_source)
      # fp_source = FiatLux::Core::File.new("fragment_shaders/simple_fp.glsl")
      # fragment_program = @device.compile_fragment_program(fp_source)

      # Bind the variables to the appropriate vertexprogram inputs.
      # device.add_binding(pos_var, vertex_program, "Position")
    end
  end
end