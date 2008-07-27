$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require File.join(File.dirname(__FILE__),'..','lib','test_base')
require File.join(File.dirname(__FILE__),'..','lib','finder')

require 'rubygems'
require 'mocha'

include Multitest

class TestBaseTest < Test::Unit::TestCase

  def test_get_test
    base = create_base
    t = base.get_test
    assert t
    %w{dir file test}.each do |attr|
      assert t[attr.to_sym]
    end
  end
  
  def test_count_tests
    assert_equal 8, create_base.count
  end
  
  def test_delete_test_after_getting_it
    base = create_base
    assert base.get_test
    assert_equal 7, base.count
  end
  
  def test_get_all_tests
    t = create_base
    tests = t.instance_variable_get(:@pending).map do |test|
      test[:tests].map {|h| {:dir => test[:dir], :file => test[:file], :test => h}}
    end.flatten
    8.times do
      test = t.get_test
      assert tests.include?(test)
      tests.delete(test)
    end
    assert_equal nil, t.get_test
    assert tests.empty?
  end
  
  protected
  
  def create_base
    dir = Dir.open(File.join(File.dirname(__FILE__),'rails_tree','test'))
    t = TestBase.new(Finder.find!(dir), File.join(File.dirname(__FILE__),'rails_tree','results'))
  end
  
end
