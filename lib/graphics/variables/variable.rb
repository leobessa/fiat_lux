module FiatLux
  module Graphics
    module Variables
      class Variable

        attr_reader :data

        def initialize(opts = {})
          @description = opts.fetch(:description)
          @data        = opts.fetch(:data)
        end

        def name
          @description.name
        end

        def type
          @description.type
        end

        def component_size
          @description.component_size
        end

      end
    end
  end
end
