# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'core_ext/mongo'

module MongoBackup
  class Cluster

    #  nodes to backup
    attr_reader :nodes

    def initialize(opts={})
      @opts = {
      }.merge(opts)



      @mongos = Mongo::MongosConnection.new( {
        :host=>@opts[:host],
        :port =>@opts[:port],
      })

      @shards = @mongos.shards.map{ |shard|
        replica = Mongo::ReplSetConnection.new_from_string( shard["host"] )
        replica.passives.map do |host|
          Mongo::Connection.new(host)
        end
      }.flatten
    end

    def run
      stop_balancer do
        lock_shards do
          backup_shards
          config.backup
          wait_backup
        end
      end
    end

    def stop_balancer
      @mongos.stop_balancer
      begin
        yield
      ensure
        @mongos.start_balancer
      end
    end

    def lock_shards
      begin
        @shards.each { |shard|  shard.lock! }
        yield
      ensure
        @shards.each { |shard|  shard.unlock! }
      end
    end
  end

end
