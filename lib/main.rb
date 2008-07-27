# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'yaml'
require 'rubygems'
require 'ruby-debug'

require File.join(File.dirname(__FILE__), 'finder')
require File.join(File.dirname(__FILE__), 'support')
require File.join(File.dirname(__FILE__), 'test_base')

Debugger.start

module Multitest
  class Tester
    @@port = 3433
    @@temp_dir = '/tmp'
    
    attr_accessor :db_count
    attr_accessor :wd
    
    def initialize(dir = nil)
      @wd = dir || Dir.getwd
    end
    
    def run
      @db_count ||= 4
      load_rails_config
      prepare_databases
      @tests = Finder.find!(Dir.open(File.join(@wd, "test")))
    end

    def load_rails_config
      @config = 
        YAML::load(File.open(File.join(@wd, 'config', 'database.yml')))['test']
    end

    def prepare_postgres
      srand
      number = rand(10**10)
      const_opts = "-U #{@config['username']}"
      dump_filepath = File.join(@@temp_dir, [number, 'sql'].join('.'))
      `pg_dump #{const_opts} -f #{dump_filepath} #{@config['database']}`
      if $? == 0
        (2..@db_count).each do |i|
          db_name = [@config['database'], i].join
          `dropdb #{const_opts} #{db_name}`
          `createdb #{const_opts} #{db_name}`
          `psql #{const_opts} #{db_name} < #{dump_filepath}`
          exit(1) if $? != 0
        end
      else
        exit 1
      end
    end

    def prepare_databases
      case @config["adapter"]
      when "postgresql"
        prepare_postgres
      else
        puts('Your database adapter is not supported!')
        exit 1
      end
    end
    
    def start_server
      DRb.start_service "druby://:7777", TestBase.new(@tests, @results_path)
    end
    
    def stop_server
      DRb.stop_service
    end
    
    def do_fork
      start_server
      @db_count.times do
        unless fork
          DRb.start_service
          ro = DRbObject.new(nil, 'druby://:7777')
          while test = ro.get_test
            require File.join(test[:dir], test[:file])
            test_class = test[:file].split(".").first.classify.constantize
            result = Test::Unit::TestResult.new
            test_class.new(test[:test]).run(result) {|s,n|}
            ro.accept_result(test, result)
          end
          exit
        end
      end
      Process.waitall
      stop_server
    end
    
    def run_all_tests
      @tests.each do |test_file_hash|
        results_file_path = File.join(@results_path, test_file_hash[:file].split(/\./)[0])
        test_file = File.join(test_file_hash[:dir], test_file_hash[:file])
        test_file_hash[:tests].each do |test_name|
          `echo "---TEST:#{test_name}" >> #{results_file_path}`
          `ruby -I.:lib:test #{test_file} -n "/^(#{test_name})$/" 2>&1 >> #{results_file_path}`
          `echo ---RESULT:#{$?} >> #{results_file_path}`
        end
      end
    end

    def start
      time = Time.now
      time = [time.strftime("%d-%m-%y_%H-%M-%S"), time.usec >> 14].join("-")
      @results_path = File.join(@wd, "multitest", "results", time)
      @results_dir = Dir.mkdir(@results_path)
      do_fork
    end
  end
end