
require 'rubygems'
require 'logger'
require 'mongo_cluster_backup/core_ext/mongo'
require 'mongo_cluster_backup/runner/abstract_runner'
require 'mongo_cluster_backup/version'

module MongoBackup
  class Cluster

    #  nodes to backup
    attr_reader :nodes

    #  general info about cluster setup
    attr_reader :metadata

    def initialize(opts={})
      @opts = {
        :runner => BackupRunner::AbstractRunner,
        :config_port => 38019,
        :sleep_period => 5,
        :logfile => STDOUT,
        :lock => true,
      }.merge(opts)

      @metadata = {
        :id => nil,
        :config => [ @opts[:host], @opts[:config_port] ],
        :shards => {}
      }

      @logger = Logger.new( @opts[:logfile] )
      if @opts[:verbose]
        @logger.level = Logger::DEBUG
      elsif @opts.delete(:quiet)
        @logger.level = Logger::WARN
      else
        @logger.level = Logger::INFO
      end

      @mongos = Mongo::MongosConnection.new( @opts[:host], @opts[:port], :logger=>@logger)

      @shards = @mongos.shards.map{ |shard|       # map{}, not each{} here!!
        replica = Mongo::ReplSetConnection.new_from_string( shard["host"], :logger=>@logger )
        replica.passives.map do |host|
          host = host.split(':')
          @metadata[:shards][shard["_id"]] = [ host[0], host[1].to_i ]
          Mongo::SafeConnection.new( host[0], host[1], :shard_name => shard["_id"] , :logger=>@logger )
        end                                       # map{}, not each{} here!!
      }.flatten

      @config = Mongo::SafeConnection.new( @opts[:host], @opts[:config_port], :shard_name => 'CONFIG', :logger=>@logger )
    end

    def run
      stop_balancer do
        lock_shards do
          backup_nodes( @shards | [ @config ] )
          wait_backup
        end
      end
      @runner.save_metadata(@metadata)
    end

    def stop_balancer
      @logger.info('Stopping balancer')
      @mongos.stop_balancer
      begin
        yield
      ensure
        @mongos.start_balancer
        @logger.info('Balancer started')
      end
    end

    def lock_shards
      if @opts[:lock]
        begin
          @logger.info("Locking nodes")
          @shards.each { |shard|  shard.lock! }
          yield
        ensure
          @shards.each { |shard|  shard.unlock! }
          @logger.info("Nodes unlocked")
        end
      else
        yield
      end
    end

    def backup_nodes( nodes )
      @logger.info("Backing up nodes")
      @runner = @opts[:runner].new( nodes, @opts )
      @runner.run
      @nodes = @runner.backups
    end

    def wait_backup
      @logger.info("Waiting for backups to finish") unless @runner.waiting.empty?
      while !@runner.waiting.empty?
        sleep @opts[:sleep_period]
        @runner.update_waiting
      end
    end

    def backup_id
      @runner.backup_id  if @runner
    end
  end

end
