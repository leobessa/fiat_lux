describe "FiatLux::Graphics::Rendering::Geometry" do

  before do
    @subject = FiatLux::Graphics::Rendering::Geometry.new
    # TODO: Setup subject variables
  end

  it "fetches vertex position attribute" do
    vertex_positions = @subject.fetch(:vertex_position)
    vertex_positions[0..2].should == [
      [-0.5, -0.5, 0.0],
      [ 0.5, -0.5, 0.0],
      [ 0.0,  0.5, 0.0]
    ]
  end

  it "fetches vertex color attribute" do
    vertex_colors = @subject.fetch(:vertex_color)
    vertex_colors[0..2].should == [
      [1.0, 0.0, 0.0],
      [0.0, 1.0, 0.0],
      [0.0, 0.0, 1.0]
    ]
  end

  it "fetches the primitive type" do
    @subject.fetch(:primitive_type)[0].should == :triangle_strip
  end

  it "fetches number of elements used" do
    @subject.fetch(:element_count)[0].should == 3
  end

  it "fetches number of elements used" do
    index_buffer = @subject.fetch(:index_buffer)
    index_buffer[0..2].should == [1,2,3]
  end

end
