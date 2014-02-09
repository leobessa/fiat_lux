module FiatLux
  module Graphics
    module Variables
      class VariableSet

        def initialize
          @hash = Hash.new
        end

        def add(variable)
          @hash[variable] = true
          self
        end
        alias :<< :add

        def each(&block)
          block or return enum_for(__method__)
          @hash.each_key(&block)
          self
        end

        def find(&block)
          each.find(&block)
        end

      end
    end
  end
end
