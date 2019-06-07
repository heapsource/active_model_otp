testdir = File.dirname(__FILE__)
$LOAD_PATH.unshift testdir unless $LOAD_PATH.include?(testdir)

libdir = File.dirname(File.dirname(__FILE__)) + '/lib'
$LOAD_PATH.unshift libdir unless $LOAD_PATH.include?(libdir)

require "rubygems"
require "active_model_otp"
require "minitest/autorun"
require "minitest/unit"
require "active_record"

begin
  require "activemodel-serializers-xml"
rescue LoadError
end

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
load "#{ File.dirname(__FILE__) }/schema.rb"

Dir["models/*.rb"].each {|file| require file }
