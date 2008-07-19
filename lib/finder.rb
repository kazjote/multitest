require 'rubygems'
require 'active_support'

module Multitest
  class Finder
    
    attr_accessor :tests
    
    def find_tests(dir)
      @tests = []
      cwd = Dir.getwd
      Dir.chdir(dir.path)
      dir.each do |entry|
          search_dir_for_tests(Dir.open(entry)) if
            File.stat(entry).directory? && !%w{. ..}.include?(entry)
      end
      Dir.chdir(cwd)
    end
    
    def search_dir_for_tests dir
      dir.each  do |entry|
        unless %w{. ..}.include?(entry)
          file_stat = File.stat(File.join(dir.path, entry))
          search_dir_for_tests(Dir.open(File.join(dir.path, entry))) if
            file_stat.directory?
          process_found_file(File.expand_path(dir.path), entry) if file_stat.file? &&
            /\.rb$/ =~ entry
        end
      end
    end
    
    def process_found_file(dir_path, entry)
      require File.join(dir_path, entry)
      @tests << {:dir => dir_path, :file => entry, :tests =>
          entry.to(-4).camelize.constantize.instance_methods.reject {|m| not /^test_/ =~ m}}
    end
    
    def self.find!(dir)
      f = Finder.new
      f.find_tests(dir)
      f.tests
    end
  end
end
