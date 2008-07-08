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

  def test_run_tests
    tree_path, tester_path, results_path = paths
    old_size = Dir.entries(results_path).entries.length
    run_tester
    assert Dir.entries(File.join(tree_path, "multitest")).include?("results")
    assert_equal old_size + 1, Dir.entries(results_path).entries.length
  end

  private

  # Returns touple [tree_path, tester_path, results_path]
  def paths
    tree_path = File.join(File.dirname(__FILE__), 'rails_tree')
    ["", "multitest", "results"].inject([tree_path]) do |result, suffix|
      result << File.join(result[-1], suffix)
    end[1..3]
  end

  def run_tester
    tree_path = paths[0]
    t = Multitest::Tester.new(tree_path)
    t.load_rails_config
    t.db_count = 2
    t.prepare_databases
    t.start
  end
end
