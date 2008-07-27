require File.join(File.dirname(__FILE__), 'activesupport', 'inflector')

module Multitest
  def add_support(string)
    string.extend(Multitest::String::Inflections)
  end
end
