# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'core_ext/mongo'

# => stub class for tests
module Mongo
  class TestConnection < SafeConnection
    attr_accessor :lock_was_run    
    def initialize
      @lock_was_run = false
      @locked = false
    end
    
    def unsafe_lock!
      @locked = true
      @lock_was_run = true
    end
    
    def locked?
      @locked
    end
    
    def unsafe_unlock!
      raise RuntimeError, "This should not be raised"
    end
  end
end

class MongoConnectionTest < Test::Unit::TestCase
  def setup
    @m=Mongo::TestConnection.new
  end

  def test_dont_run_lock_when_locked
    @m.lock!
    assert @m.locked?
    @m.lock_was_run = false
    @m.lock!
    assert !@m.lock_was_run
  end

  def test_rescue_during_unlock
    assert_nothing_raised do
      @m.unlock!
    end
  end
end
