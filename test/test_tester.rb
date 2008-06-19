# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require File.join(File.dirname(__FILE__),'..','lib','main')

class TestTester < Test::Unit::TestCase
  def test_load_rails_config
    t = Multitest::Tester.new(File.join(File.dirname(__FILE__), 'rails_tree'))
    t.load_rails_config
    assert_equal 'mamily_test', t.instance_variable_get(:@config)['database']
  end
  
  def test_prepare_databases
    puts('This test may fail if you don\'t have test environment prepared! See README')
    t = Multitest::Tester.new(File.join(File.dirname(__FILE__), 'rails_tree'))
    t.load_rails_config
    t.db_count = 2
    t.prepare_databases
    assert true
  end
end
