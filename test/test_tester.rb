# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require File.join(File.dirname(__FILE__),'..','lib','main')

require 'rubygems'
require 'mocha'

(1..2).each do |i|
  require File.join(File.dirname(__FILE__), 'rails_tree', "test", "functional", "test_func#{i}")
  require File.join(File.dirname(__FILE__), 'rails_tree', "test", "unit", "unit_test#{i}")
end

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
  
  def test_execute_all_tests
    tree_path, tester_path, results_path = paths
    tester = run_tester
    results = %w{test_func1 test_func2 unit_test1 unit_test2}.inject([]) do |array, file|
      array << File.open(File.join(tester.instance_variable_get(:@results_path),
          file), "r").readlines
    end.flatten
    %w{test_one test_two test_2}.each do |test_name|
      assert !results.select {|l| Regexp.new(test_name) =~ l}.compact.empty?
    end
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
    t.db_count = 2
    t.run
    t.start
    t
  end
end
