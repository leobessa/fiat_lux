module FiatLux
  module Graphics
    module Variables
      class VariableDescription

        attr_reader :name, :type, :frequency, :shareable, :geometry_related, :component_size

        def initialize(opts = {})
          @name = opts.fetch(:name)
          @type = opts.fetch(:type)
          @frequency = opts.fetch(:frequency)
          @shareable = opts.fetch(:shareable)
          @geometry_related = opts.fetch(:geometry_related)
          @component_size = opts.fetch(:component_size){ 1 }
        end

      end
    end
  end
end
