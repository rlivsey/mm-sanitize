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

end
