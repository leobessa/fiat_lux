class EaglView < UIView

  attr_accessor :context

  def initialize
    super
    setup
    self
  end
  
  def initWithFrame(*args)
    super
    setup
    self
  end

  def setup
    # we don't want a transparent surface
    self.layer.opaque = true
    # here we configure the properties of our canvas, most important is the color depth RGBA8 !
    self.layer.drawableProperties = {
      KEAGLDrawablePropertyRetainedBacking => false,
      KEAGLDrawablePropertyColorFormat => KEAGLColorFormatRGBA8
    }
    
    # create an OpenGL ES 2 context
    # @context = EAGLContext.alloc.initWithAPI KEAGLRenderingAPIOpenGLES2
    #
    # # if this failed or we cannot set the context for some reason, quit
    # if (!@context || !EAGLContext.setCurrentContext(@context))
    #   fail("Could not create context!")
    # end

    # do we want to use a depth buffer?
    # for 3D applications we usually do, so we'll set it to true by default
    @use_depth_buffer = false;
    # default values for our OpenGL buffers
    @defaultFramebuffer = 0;
    @colorRenderbuffer = 0;
    @depthRenderbuffer = 0;
    @framebufferWidth = 0;
    @framebufferHeight = 0;
  end

  def self.layerClass
    CAEAGLLayer
  end

  def createFramebuffer
    #this method assumes, that the context is valid and current, and that the default framebuffer has not been created yet!
    #this works, because as soon as we call glGenFramebuffers the value will be > 0
    fail unless @defaultFramebuffer == 0
    # puts "EAGLView: creating Framebuffer"
    # Create default framebuffer object and bind it
    @defaultFramebuffer = Pointer.new('I').tap { |ptr| glGenFramebuffers(1, ptr) }.value
    glBindFramebuffer(GL_FRAMEBUFFER, @defaultFramebuffer)
    # Create color render buffer
    @colorRenderbuffer = Pointer.new('I').tap { |ptr| glGenRenderbuffers(1, ptr) }.value
    glBindRenderbuffer(GL_RENDERBUFFER, @colorRenderbuffer)
    #get the storage from iOS so it can be displayed in the view
    @context.renderbufferStorage(GL_RENDERBUFFER, fromDrawable: self.layer)
    #get the frame's width and height
    @framebufferWidth = Pointer.new('i').tap { |ptr| glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH,ptr) }.value
    @framebufferHeight = Pointer.new('i').tap { |ptr| glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT,ptr) }.value
    #attach this color buffer to our framebuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, @colorRenderbuffer)
    glViewport(0, 0, @framebufferWidth, @framebufferHeight)
    if @use_depth_buffer
      #create a depth renderbuffer
      @depthRenderbuffer = Pointer.new('I').tap { |ptr| glGenRenderbuffers(1, ptr) }.value
      glBindRenderbuffer(GL_RENDERBUFFER, @depthRenderbuffer);
      #create the storage for the buffer, optimized for depth values, same size as the colorRenderbuffer
      glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, @framebufferWidth, @framebufferHeight);
      #attach the depth buffer to our framebuffer
      glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, @depthRenderbuffer);
    end
    #check that our configuration of the framebuffer is valid
    status = glCheckFramebufferStatus(GL_FRAMEBUFFER)
    case status
    when GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT
      fail("Failed to make complete framebuffer object GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT")
    when GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS
      fail("Failed to make complete framebuffer object GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS")
    when GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT
      fail("Failed to make complete framebuffer object GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT")
    when GL_FRAMEBUFFER_UNSUPPORTED
      fail("Failed to make complete framebuffer object GL_FRAMEBUFFER_UNSUPPORTED")
    when GL_FRAMEBUFFER_UNDEFINED
      fail("Failed to make complete framebuffer object GL_FRAMEBUFFER_UNDEFINED")
    else
      fail("Failed to make complete framebuffer object %i" % glCheckFramebufferStatus(GL_FRAMEBUFFER)) if status != GL_FRAMEBUFFER_COMPLETE
    end
  end

  def deleteFramebuffer
    # we need a valid and current context to access any OpenGL methods
    if @context
      EAGLContext.setCurrentContext @context
      # if the default framebuffer has been set, delete it.
      if @defaultFramebuffer
        Pointer.new('I').tap { |ptr| ptr[0] = @defaultFramebuffer; glDeleteFramebuffers(1, ptr) }
        @defaultFramebuffer = 0
      end
      # same for the renderbuffers, if they are set, delete them
      if @colorRenderbuffer
        Pointer.new('I').tap { |ptr| ptr[0] = @colorRenderbuffer; glDeleteFramebuffers(1, ptr) }
        @colorRenderbuffer = 0
      end
      if @depthRenderbuffer
        Pointer.new('I').tap { |ptr| ptr[0] = @depthRenderbuffer; glDeleteFramebuffers(1, ptr) }
        @depthRenderbuffer = 0
      end
    end
  end

  def drawFrame
    # we need a context for rendering
    if @context
      # make it the current context for rendering
      EAGLContext.setCurrentContext @context
      # if our framebuffers have not been created yet, do that now!
      createFramebuffer if @defaultFramebuffer == 0
      glBindFramebuffer(GL_FRAMEBUFFER, @defaultFramebuffer);
      # we need a lesson to be able to render something
      # glClearColor(0.0, 0.0, 1.0, 1.0)
      # glClear(GL_COLOR_BUFFER_BIT)
      yield if block_given?
      # finally, get the color buffer we rendered to, and pass it to iOS
      # so it can display our awesome results!
      glBindRenderbuffer(GL_RENDERBUFFER, @colorRenderbuffer)
      context.presentRenderbuffer GL_RENDERBUFFER
    else
      fail("Context not set!")
    end
  end

  def render_buffer_image
    # allocate array and read pixels into it.
    image_width = @framebufferWidth
    image_height = @framebufferHeight
    buffer_size = image_width*image_height*4
    pixels_ptr = Pointer.new('C',buffer_size)
    glReadPixels(0, 0, image_width, image_height, GL_RGBA, GL_UNSIGNED_BYTE, pixels_ptr);
    # make data provider with data.
    provider = CGDataProviderCreateWithData(nil, pixels_ptr, buffer_size, CGDataProviderDirectCallbacks.new.releaseBytePointer);
    # prep the ingredients
    bits_per_component = 8;
    bits_per_pixel = 32;
    bytes_per_row = 4 * image_width;
    color_space_ref = CGColorSpaceCreateDeviceRGB()
    bitmap_info = KCGImageAlphaPremultipliedLast
    rendering_intent = KCGRenderingIntentDefault
    # make the cgimage
    image_ref = CGImageCreate(image_width, image_height, bits_per_component, bits_per_pixel, bytes_per_row, color_space_ref, bitmap_info, provider, nil, false, rendering_intent);
    # then make the uiimage from that
    result_image =  UIImage.imageWithCGImage image_ref
    CGDataProviderRelease(provider)
    CGImageRelease(image_ref)
    CGColorSpaceRelease(color_space_ref)
    result_image
  end

  attr_writer :use_depth_buffer

  #As soon as the view is resized or new subviews are added, this method is called,
  #apparently the framebuffers are invalid in this case so we delete them
  #and have them recreated the next time we draw to them
  def layoutSubviews
    self.deleteFramebuffer
  end
  
end

class EaglViewController < UIViewController

end

module FiatLux::Graphics::Rendering
  describe '' do

    tests EaglViewController

    it 'can generate a triangle' do
      controller.view = EaglView.alloc.initWithFrame(window.bounds)
      # given a OpenGL ES 2.0 context
      context = OpenGL::ContextFactory.new.create(api_version: 2)
      
      # and a OpenGL ES 2.0 driver
      driver = OpenGL::ES2::Driver.new
      # when I create a OpenGL device with the context and the driver
      device = OpenGL::ES2::Device.new(context: context, driver: driver)
      controller.view.context = context.eagl_context
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

      device.program_pipeline = device.create_pipeline_program(vertex_shader: vertex_shader, fragment_shader: fragment_shader)
      # Create a variable description.
      position_variable_description = FiatLux::Graphics::Variables::VariableDescription.new(
        name: "VertexPosition",
        type: :float,
        component_size: 3,
        frequency: :each_vertex,
        shareable: true,
        geometry_related: true
      )
      # Create a position variable.
      # Fill the variable data.
      position_variable = FiatLux::Graphics::Variables::Variable.new(
        description: position_variable_description,
        data: [
          [ 0.0, 0.5, 0.0],
          [-0.5,-0.5, 0.0],
          [ 0.5,-0.5, 0.0]
        ]
      )
      # Create variables indicating primitive type and element count.
      type_variable_description = FiatLux::Graphics::Variables::VariableDescription.new(
        name: "PrimitiveType",
        type: :ulong,
        frequency: :each_primitive,
        shareable: true,
        geometry_related: false
      )
      type_variable = FiatLux::Graphics::Variables::Variable.new(
        description: type_variable_description,
        data: [GL_TRIANGLES]
      )

      count_variable_description = FiatLux::Graphics::Variables::VariableDescription.new(
        name: "ElementCount",
        type: :long,
        frequency: :each_primitive,
        shareable: true,
        geometry_related: false
      )
      count_variable = FiatLux::Graphics::Variables::Variable.new(
        description: count_variable_description, data: [3]
      )
      # Collect the variables.
      variable_set = FiatLux::Graphics::Variables::VariableSet.new
      variable_set << position_variable
      variable_set << type_variable
      variable_set << count_variable
      # Create geometry from variables.
      geometry = device.create_geometry
      geometry.variables = variable_set
      # Bind the variables to the appropriate vertexprogram inputs.
      device.add_binding(variable: position_variable, program: vertex_shader, name: "vPosition")
      # Rendering loop
      controller.view.drawFrame do
        # Load vertex data
        # Bind the variables to the appropriate vertexprogram inputs.
        # device.add_binding(pos_var, vertex_program, "Position")
        geometry.draw
      end
      actual_image = controller.view.render_buffer_image
      expected_image = UIImage.imageWithContentsOfFile(NSBundle.mainBundle.pathForResource "fixtures/triangle", ofType:"png")
      # save_to_file("triangle.png",controller.view.render_buffer_image)
      (UIImagePNGRepresentation(actual_image).isEqualToData UIImagePNGRepresentation(expected_image)).should.be.true
    end
    
    def documents_path
      NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0]
    end

    def resources_path
      NSBundle.mainBundle.resourcePath
    end

    def save_to_file(file_name,image)
      path = "#{documents_path}/#{file_name}";
      data = UIImagePNGRepresentation( image )
      data.writeToFile path, atomically: true
    end
  end
end