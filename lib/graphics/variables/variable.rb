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

        def components
          @description.components
        end

      end
    end
  end
end
