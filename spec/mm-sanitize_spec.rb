require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'pp'

describe "MongoMapper::Plugins::Sanitize" do

  describe "sanitizing an individual field" do

    before(:each) do
      @doc_class = Doc do
        plugin MongoMapper::Plugins::Sanitize

        sanitize :body

        key :body, String
        key :title, String
      end
    end

    it "should sanitize the specified field" do
      doc = @doc_class.new(:body => '<b><a href="/">something</a></b>')
      doc.valid?
      doc.body.should == "something"
    end

    it "should not touch other fields" do
      doc = @doc_class.new(:title => '<b><a href="/">something</a></b>')
      lambda {
        doc.valid?
      }.should_not change(doc, :title)
    end

    it "should keep the original value in original_body" do
      doc = @doc_class.new(:body => '<b><a href="/">something</a></b>')
      lambda {
        doc.valid?
      }.should change(doc, :original_body).from(nil).to('<b><a href="/">something</a></b>')
    end

  end

  describe "sanitizing an individual field with a config" do

    before(:each) do
      @doc_class = Doc do
        plugin MongoMapper::Plugins::Sanitize

        sanitize :body, :config => Sanitize::Config::RESTRICTED

        key :body, String
        key :title, String
      end
    end

    it "should sanitize the specified field with the config" do
      doc = @doc_class.new(:body => '<b><a href="/">something</a></b>')
      doc.valid?
      doc.body.should == "<b>something</b>"
    end

  end

  describe "skip storing original value" do

    before(:each) do
      @doc_class = Doc do
        plugin MongoMapper::Plugins::Sanitize

        sanitize :body, :keep_original => false

        key :body, String
        key :title, String
      end
    end

    it "should not keep the original value in original_body" do
      @doc_class.keys["original_body"].should be_nil
    end

  end

  describe "sanitizing multiple fields" do

    before(:each) do
      @doc_class = Doc do
        plugin MongoMapper::Plugins::Sanitize

        sanitize :body, :title

        key :body, String
        key :title, String
      end
    end

    it "should sanitize all specified fields" do
      doc = @doc_class.new(:body => '<b><a href="/">something</a></b>', :title => '<b><a href="/">title</a></b>')
      doc.valid?
      doc.body.should == "something"
      doc.title.should == "title"
    end

  end

  describe "sanitizing fields with different configs" do

    before(:each) do
      @doc_class = Doc do
        plugin MongoMapper::Plugins::Sanitize

        sanitize :body
        sanitize :title, :config => Sanitize::Config::RESTRICTED

        key :body, String
        key :title, String
      end
    end

    it "should sanitize all specified fields with their respective config" do
      doc = @doc_class.new(:body => '<b><a href="/">something</a></b>', :title => '<b><a href="/">title</a></b>')
      doc.valid?
      doc.body.should == "something"
      doc.title.should == "<b>title</b>"
    end

  end

  describe "sanitizing complex fields" do

    before(:each) do
      @doc_class = Doc do
        plugin MongoMapper::Plugins::Sanitize

        sanitize :set_field, :hash_field, :array_field

        key :set_field,   Set
        key :hash_field,  Hash
        key :array_field, Array
      end
    end

    it "should sanitize the contents of arrays" do
      doc = @doc_class.new(:array_field => ["<i>one</i>", "<b>two</b>"])
      doc.valid?
      doc.array_field.should == ["one", "two"]
    end

    it "should sanitize the contents of sets" do
      doc = @doc_class.new(:set_field => ["<i>one</i>", "<b>two</b>"])
      doc.valid?
      doc.set_field.to_a.sort.should == ["one", "two"]
    end

    it "should sanitize the contents of hashes" do
      doc = @doc_class.new(:hash_field => {:one => "<b>testing</b>", :two => "<b>something</b>"})
      doc.valid?
      doc.hash_field[:one].should == "testing"
      doc.hash_field[:two].should == "something"
    end
  end

  describe "model with no sanitizing" do

    before(:each) do
      @doc_class = Doc do
        plugin MongoMapper::Plugins::Sanitize

        key :body, String
      end
    end

    it "should not change anything" do
      doc = @doc_class.new(:body => '<b><a href="/">something</a></b>')
      lambda {
        doc.valid?
      }.should_not change(doc, :body)
    end

  end
end
