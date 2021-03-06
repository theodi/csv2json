require 'coveralls'
Coveralls.wear_merged!('test_frameworks')

$:.unshift File.join( File.dirname(__FILE__), "..", "..", "lib")

require 'rspec/expectations'
require 'cucumber/rspec/doubles'
require 'csvlint/csvw/csv2json/csv2json'
require 'pry'

require 'spork'

Spork.each_run do
  require 'csvlint/csvw/csv2json/csv2json'
end

class CustomWorld
  def default_csv_options
    return {
    }
  end
end

World do
  CustomWorld.new
end
