module FiatLux
  module Graphics
    module DrawGraph
      class Camera

        attr_accessor :position, :target

        def initialize(args = {})
          @math_factory = args.fetch(:math_factory)
          @position = args.fetch(:position){ @math_factory.build_position(0.0,0.0,1.0) }
          @target   = args.fetch(:target)  { @math_factory.build_position(0.0,0.0,0.0) }
        end

      end
    end
  end
end
