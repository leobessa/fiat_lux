module FiatLux
  module Graphics
    module Rendering
      module OpenGL
        module Library
          module ClassMethods
            def attach_function(function_name, opts = {})
              delegate = opts.fetch(:to)
              source_method_name = :"#{function_name}_source"
              instance_variable_name = :"@#{source_method_name}"
              attr_writer source_method_name
              define_method(source_method_name) do
                unless instance_variable_defined?(instance_variable_name)
                  instance_variable_set(instance_variable_name, delegate)
                end
                instance_variable_get(instance_variable_name)
              end
              define_method(function_name) { |*args| send(source_method_name).call(*args) }
            end
          end

          module InstanceMethods
          end

          def self.included(receiver)
            receiver.extend         ClassMethods
            receiver.send :include, InstanceMethods
          end
        end
      end
    end
  end
end