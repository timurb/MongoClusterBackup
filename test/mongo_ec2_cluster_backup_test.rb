# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'mongo_ec2_cluster_backup'
require 'ec2_proxy'

module Mongo
  class MongosConnection
    def initialize(mongos)
      @host=mongos[:host]
      @port=mongos[:port]
      @balancer=:started
    end

    def stop_balancer
      @balancer=:stopped
    end

    def start_balancer
      @balancer=:started
    end

    def shards
      [
        { "_id" => "shard1",
          "host" => "repl1/repl1a:27018,repl1b:27018,repl1c:27018" },
        { "_id" => "shard2",
          "host" => "repl2/repl2a:27018,repl2b:27018,repl2c:27018" },
        { "_id" => "shard3",
          "host" => "repl3/repl3a:27018,repl3b:27018,repl3c:27018" },
        ]
    end
  end
end

class MongoEC2ClusterBackupTest < Test::Unit::TestCase

  MONGOS={
    :host => 'localhost',
    :port => 27017,
  }

  def setup
    @backup=MongoBackup::Cluster.new( MONGOS )
    @backup.run

    @ec2=EC2Proxy.new
  end

  def test_nodes_backupped
    @backup.nodes.each { |node| assert_true @ec2.snapshots.include?(node) }
  end
end
