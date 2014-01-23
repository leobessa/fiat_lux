describe "FiatLux::Graphics::DrawGraph::Camera" do

  class FakeMathFactory
    def build_position(x,y,z)
      [x,y,z]
    end
  end

  it "has default position vector" do
    math_factory = FakeMathFactory.new
    @subject = FiatLux::Graphics::DrawGraph::Camera.new(math_factory: math_factory)
    @subject.position.should == math_factory.build_position(0.0,0.0,1.0)
  end

  it "has default target vector" do
    math_factory = FakeMathFactory.new
    @subject = FiatLux::Graphics::DrawGraph::Camera.new(math_factory: math_factory)
    @subject.target.should == math_factory.build_position(0.0,0.0,0.0)
  end

end
