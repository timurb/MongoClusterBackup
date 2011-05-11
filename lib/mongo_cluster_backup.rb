
require 'rubygems'
require 'core_ext/mongo'
require 'abstract_backup_runner'

module MongoBackup
  class Cluster

    #  nodes to backup
    attr_reader :nodes

    def initialize(opts={})
      @opts = {
        :runner => AbstractBackupRunner,
        :config_port => 38019,
        :sleep_period => 5,
      }.merge(opts)



      @mongos = Mongo::MongosConnection.new( {
        :host=>@opts[:host],
        :port =>@opts[:port],
      })

      @shards = @mongos.shards.map{ |shard|       # map{}, not each{} here!!
        replica = Mongo::ReplSetConnection.new_from_string( shard["host"] )
        replica.passives.map do |host|
          Mongo::SafeConnection.new( host[0], host[1], { :shard_name => shard["_id"] } )
        end                                       # map{}, not each{} here!!
      }.flatten

      @config = Mongo::SafeConnection.new( @opts[:host], @opts[:config_port], :shard_name => 'CONFIG' )
    end

    def run
      stop_balancer do
        lock_shards do
          backup_nodes( @shards | [ @config ] )
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

    def backup_nodes( nodes )
      @runner = @opts[:runner].new( nodes )
      @runner.run
      @nodes = @runner.backups
    end

    def wait_backup
      while !@runner.waiting.empty?
        sleep @opts[:sleep_period]
        @runner.update_waiting
      end
    end
  end

end
