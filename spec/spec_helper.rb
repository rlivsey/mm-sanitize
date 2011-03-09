$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'

require 'mm-sanitize'

MongoMapper.database = 'mm-sanitize-spec'

def Doc(name=nil, &block)
  klass = Class.new do
    include MongoMapper::Document
    set_collection_name :test

    if name
      class_eval "def self.name; '#{name}' end"
      class_eval "def self.to_s; '#{name}' end"
    end
  end

  klass.class_eval(&block) if block_given?
  klass.collection.remove
  klass
end

RSpec.configure do |config|
end
