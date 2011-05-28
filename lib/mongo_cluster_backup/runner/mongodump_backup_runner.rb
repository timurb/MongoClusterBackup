
require 'mongo_cluster_backup/runner/abstract_backup_runner'

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
          system( 'mongodump', '-o', File.join(@opts[:backup_path],node.shard_name), '-h', node.host, '--port', node.port.to_s )
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

    end
  end
end
