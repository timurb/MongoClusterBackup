
require 'mongo_cluster_backup/runner/abstract_runner'
require 'yaml'

module MongoBackup
  module BackupRunner
    class MongoDumpRunner < AbstractRunner

      def initialize(*args)
        super
        @opts[:backup_path] = File.join( ( @opts[:backup_dir] || Dir.pwd ), @backup_id )
        @stdout = STDOUT.dup
        @null = File.open('/dev/null','w')
      end

      def backup_node(node)
        begin
          STDOUT.reopen(@null)   unless @opts[:verbose]
          system( *%W[mongodump -o #{File.join(@opts[:backup_path],node.shard_name)} -h #{node.host} --port #{node.port}] )
        ensure
          begin
            STDOUT.reopen(@stdout)  unless @opts[:verbose]
          rescue => e
            STDOUT.reopen(STDERR)
            raise e
          end
        end
      end

      def update_waiting
        @waiting = []
      end

      def save_metadata(metadata)
        metadata[:id] = @backup_id

        File.open( File.join(@opts[:backup_path], 'METADATA.yml') ,'w' ) do |f|
          YAML.dump(metadata, f)
        end
      end
    end
  end
end
