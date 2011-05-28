# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'mongo_cluster_backup'
require 'mongo_cluster_backup/runner/dummy_backup_runner'

#  helpers go here
module Mongo
  class MongosConnection
    def initialize(host,port,opts={})
      @host=host
      @port=port
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

  class SafeConnection

    attr_reader :host_to_try

    def setup(*args)
      @args=args
      @locked = false
    end

    def lock!
      @locked = true
    end

    def unlock!
      @locked = false
    end
  end

  class ReplSetConnection

    def initialize(*args)
      @args=args
    end

    def passives
      [ @args[1].join(":") ]
    end
  end
end
# helpers finished


# actual tests
class MongoClusterBackupTest < Test::Unit::TestCase

  DEFAULT_CONFIG_PORT=38019
  BACKUP_ID='Backup ID'

  MONGOS={
    :host => 'localhost',
    :port => 27017,
    :runner => MongoBackup::BackupRunner::DummyRunner,
    :backup_id => BACKUP_ID,
    :quiet=>true,
  }

  BACKUPS=[ ["repl1b", 27018,"shard1"], ["repl2b", 27018, "shard2"], ["repl3b", 27018, "shard3"], [ MONGOS[:host], DEFAULT_CONFIG_PORT, 'CONFIG'] ]

  def setup
    @backup=MongoBackup::Cluster.new( MONGOS )
    @backup.run
  end

  def test_nodes_backupped
    assert_equal BACKUP_ID, @backup.backup_id
    assert_equal BACKUPS, @backup.nodes.map{|node|   node.host_to_try << node.shard_name }
  end
end
