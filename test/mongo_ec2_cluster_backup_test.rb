# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'mongo_ec2_cluster_backup'
require 'ec2_proxy'

class MongoEC2ClusterBackupTest < Test::Unit::TestCase

  class MongosTestProxy
    attr_reader :host
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
  end

  MONGOS={
    :host => 'localhost',
    :port => 27017,
    :mongos_proxy=>MongosTestProxy,
  }

  def setup
    @backup=MongoBackup::Cluster.new(MONGOS )
    @backup.run

    @ec2=EC2Proxy.new
  end

  def test_nodes_backupped
    @backup.nodes.each { |node| assert_true @ec2.snapshots.include?(node) }
  end
end
