module FiatLux
  module Graphics
    module Rendering
      class Primitive
        attr_reader :type, :count, :starting_index
        def initialize(opts = {})
          @type  = opts.fetch(:type)
          @count = opts.fetch(:count)
          @starting_index = opts.fetch(:starting_index){0}
        end
      end
      class Geometry

        attr_accessor :variables

        def initialize
          @variables = FiatLux::Graphics::Variables::VariableSet.new
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

        def draw
          position_variable = @variables.find { |e| e.name == "VertexPosition" }
          data = position_variable.data.flatten
          vertices_ptr  = Pointer.new(position_variable.type, data.count)
          data.each_with_index { |e,index| vertices_ptr[index] = e }

          each_primitive do |primitive|
            index = 0 # = glGetAttribLocation(program, "position");
            glVertexAttribPointer(index,3,GL_FLOAT,GL_FALSE,0,vertices_ptr)
            glEnableVertexAttribArray(index)
            glDrawArrays(primitive.type,primitive.starting_index,primitive.count)
          end
        end

        def each_primitive(&block)
          block or return enum_for(__method__)
          primitive_type = @variables.find { |e| e.name == "PrimitiveType" }
          element_count  = @variables.find { |e| e.name == "ElementCount" }
          primitive_type.data.zip(element_count.data).each do |(type,count)|
            yield Primitive.new(type: type, count: count)
          end
        end

      end
    end
  end
end
