# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'mongo_cluster_backup/core_ext/mongo'

class ReplSetConnectionTest < Test::Unit::TestCase
  REPL_SET = "name/host1,host1:27018,:27018,host3"
  PARSE_RESULT = [["host1", nil], ["host1", 27018], ["host3", nil], {:rs_name=>"name"}]

  def test_split_names
    parse_result = Mongo::ReplSetConnection.split_names(REPL_SET)
    assert_equal PARSE_RESULT, parse_result
  end
end
