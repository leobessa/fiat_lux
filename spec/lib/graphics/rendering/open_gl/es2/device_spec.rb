module FiatLux::Graphics::Rendering::OpenGL::ES2
  describe Device do
    describe '#create_vertex_shader' do
      it 'calls create_shader_program on OpenGL driver' do
        context = Object.new
        driver_mock = mock("OpenGL Driver")
        shader_source = <<-eos
          attribute vec4 vPosition;
          void main(){
            gl_Position = vPosition;
          }
        eos
        driver_mock.should_receive(:create_shader_program, with: [:vertex_shader,shader_source], return: 1)
        subject = Device.new(context: context, driver: driver_mock)
        subject.create_vertex_shader(source: shader_source)
        driver_mock.expectations.should == []
      end
    end
    describe '#create_fragment_shader' do
      it 'calls create_shader_program on OpenGL driver' do
        context = Object.new
        driver_mock = mock("OpenGL Driver")
        shader_source = <<-eos
          precision mediump float;
          void main(){
            gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
          }
        eos
        driver_mock.should_receive(:create_shader_program, with: [:fragment_shader,shader_source], return: 1)
        subject = Device.new(context: context, driver: driver_mock)
        subject.create_fragment_shader(source: shader_source)
        driver_mock.expectations.should == []
      end
    end
  end
end