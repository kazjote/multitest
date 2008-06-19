# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'yaml'
require 'rubygems'
require 'ruby-debug'

require 'finder'

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
      @tests = Finder.new(Dir.open(File.join(@wd, test))).tests
      
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
  end
end