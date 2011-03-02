require 'mongo_mapper'
require 'sanitize'

module MongoMapper
  module Plugins
    module Sanitize
      def self.included(model)
        model.plugin self
      end

      module ClassMethods
        def sanitize(*args)
          unless defined?(sanitize_keys)
            class_attribute :sanitize_keys
          end

          options = {
            :config         => {},
            :keep_original  => true
          }

          if args.last.is_a?(Hash)
            options = options.merge(args.pop)
          end

          self.sanitize_keys ||= {}
          args.each do |key_name|
            self.sanitize_keys[key_name] = options

            if options[:keep_original]
              if key_definition = self.keys[key_name]
                key_type = key_definition.type
              else
                key_type = String
              end

              self.key :"original_#{key_name}", key_type
            end
          end

          self.send(:before_validation, :sanitize_attributes)
        end
      end

      module InstanceMethods
        def sanitize_attributes
          self.class.sanitize_keys.each do |key, options|

            if options[:keep_original]
              self["original_#{key}"] = self[key]
            end

            if val = self[key]
              if val.is_a?(Array) || val.is_a?(Set)
                self[key] = val.collect{|v| ::Sanitize.clean(v, options[:config]) }
              elsif val.is_a?(Hash)
                self[key] = val.each{|k, v| val[k] = ::Sanitize.clean(v, options[:config]) if v.is_a?(String) }
              elsif val.is_a?(String)
                self[key] = ::Sanitize.clean(val, options[:config])
              end
            end
          end
        end
      end
    end
  end
end