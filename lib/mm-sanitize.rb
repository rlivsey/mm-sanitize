require 'mongo_mapper'
require 'sanitize'

module MongoMapper
  module Plugins
    module Sanitize
      def self.included(model)
        model.plugin self
      end

      def self.configure(base)
        base.before_validation :sanitize_attributes
      end

      module ClassMethods
        def sanitize(*keys)
          options = keys.pop if keys.last.is_a?(Hash)
          options ||= {}

          @sanitize_keys ||= {}
          keys.each do |key|
            @sanitize_keys[key] = options[:config]
          end
        end

        class_eval do
          attr_reader :sanitize_keys
        end
      end

      module InstanceMethods
        def sanitize_attributes
          self.class.sanitize_keys.each do |key, config|
            self[key] = ::Sanitize.clean(self[key], config || {})
          end
        end
      end
    end
  end
end