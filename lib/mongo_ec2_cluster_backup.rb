# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'mongo'

module MongoBackup
  class Cluster
    attr_reader :shards

    #  nodes to backup
    attr_reader :nodes

    def initialize(opts={})
      @opts = {
        :mongos_proxy => MongoS,
      }.merge(opts)



      @mongos = @opts[:mongos_proxy].new( {
        :host=>@opts[:host],
        :port =>@opts[:port],
      })
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
        shards.each { |shard|  shard.lock! }
        yield
      ensure
        shards.each { |shard|  shard.unlock! }
      end
    end
  end

  class MongoS < ::Mongo::Connection
    def stop_balancer
      self['config']['settings'].update( { :_id => "balancer" }, { :stopped => true } )
    end

    def start_balancer
      self['config']['settings'].update( { :_id => "balancer" }, { :stopped => false } )
    end

    def shards
      self['admin'].command( { :listShards => 1} )["shards"]
    end
  end

end
