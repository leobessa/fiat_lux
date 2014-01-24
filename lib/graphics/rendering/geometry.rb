module FiatLux
  module Graphics
    module Rendering
      class Geometry

        def initialize
          @stub = {
            vertex_position: [[-0.5, -0.5, 0.0],[ 0.5, -0.5, 0.0],[ 0.0, 0.5, 0.0]],
            vertex_color:    [[ 1.0,  0.0, 0.0],[ 0.0,  1.0, 0.0],[ 0.0, 0.0, 1.0]],
            primitive_type: [:triangle_strip],
            element_count: [3],
            index_buffer: [1,2,3]
          }
        end

        def fetch(key,&blk)
          @stub.fetch(key,&blk)
        end

      end
    end
  end
end
