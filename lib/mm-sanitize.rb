require 'mongo_mapper'
require 'sanitize'

module MongoMapper
  module Plugins
    module Sanitize
      def self.included(model)
        model.plugin self
      end

      module ClassMethods
        def sanitize(*keys)
          unless defined?(sanitize_keys)
            class_attribute :sanitize_keys
          end

          options = keys.pop if keys.last.is_a?(Hash)
          options ||= {}

          self.sanitize_keys ||= {}
          keys.each do |key|
            self.sanitize_keys[key] = options[:config]
          end

          self.send(:before_validation, :sanitize_attributes)
        end
      end

      module InstanceMethods
        def sanitize_attributes
          self.class.sanitize_keys.each do |key, config|
            config ||= {}

            if val = self[key]
              if val.is_a?(Array) || val.is_a?(Set)
                self[key] = val.collect{|v| ::Sanitize.clean(v, config) }
              elsif val.is_a?(Hash)
                self[key] = val.each{|k, v| val[k] = ::Sanitize.clean(v, config) if v.is_a?(String) }
              elsif val.is_a?(String)
                self[key] = ::Sanitize.clean(val, config)
              end
            end
          end
        end
      end
    end
  end
end