# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'rubygems'
require 'ruby-debug'
Debugger.start
require File.join(File.dirname(__FILE__),'..','lib','finder')

class TestFinder < Test::Unit::TestCase
  def setup
    @finder = Multitest::Finder.new
  end
  
  def test_find_all_files
    @finder.find_tests(Dir.open(File.join(File.dirname(__FILE__),'rails_tree','test')))
    expected = {'unit_test1.rb' => 'unit',
        'unit_test2.rb' => 'unit',
        'test_func1.rb' => 'functional',
        'test_func2.rb' => 'functional'}
    @finder.instance_variable_get(:@tests).each do |found|
      expected.delete(found[:file]) if /#{expected[found[:file]]}/ =~ found[:dir]
    end
    assert_equal 0, expected.size
  end
  
  def test_not_find_files_in_top_dir
    @finder.find_tests(Dir.open(File.join(File.dirname(__FILE__),'rails_tree','test')))
    @finder.instance_variable_get(:@tests).each do |found|
      assert_not_equal 'test_helper.rb', found[:file]
    end
  end
  
  def test_find_all_tests
    @finder.find_tests(Dir.open(File.join(File.dirname(__FILE__),'rails_tree','test')))
    @finder.instance_variable_get(:@tests).each do |found|
      %w{test_one test_two}.each {|n| assert found[:tests].include?(n)} if 
        found[:file] == 'unit_test1.rb'
    end
  end
  
  def test_not_return_non_tests
    @finder.find_tests(Dir.open(File.join(File.dirname(__FILE__),'rails_tree','test')))
    @finder.instance_variable_get(:@tests).each do |found|
      assert !found[:tests].include?("not_a_test") if 
        found[:file] == 'unit_test1.rb'
    end
  end
end
