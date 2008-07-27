module Multitest
  class TestBase
    def initialize(tests, results_path)
      @pending = tests.reject {|t| t[:tests].empty?}.compact
      @results_path = results_path
    end
    
    def get_test
      return nil if @pending.empty?
      t = {:test => @pending.first[:tests].delete_at(0),
          :dir => @pending.first[:dir],
          :file => @pending.first[:file]}
      @pending.delete_at(0) if @pending.first[:tests].empty?
      t
    end
    
    def count
      @pending.inject(0) {|s, t| s + t[:tests].length}
    end
    
    def accept_result(test, result)
      test_file = File.join(test[:dir], test[:file])
      results_file_path = File.join(@results_path, test[:file].split(".").first)
      file = File.open(results_file_path, "w+")
      file.puts("---TEST:#{test[:test]}")
      file.puts(result)
      file.puts("---RESULT:#{$?}")
      file.close
    end
  end
end
