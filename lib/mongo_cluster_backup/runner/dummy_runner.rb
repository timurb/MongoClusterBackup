
require 'mongo_cluster_backup/runner/abstract_runner'

module MongoBackup
  module BackupRunner
    class DummyRunner < AbstractRunner
      def backup_node(node)
        node
      end
      def update_waiting
        @waiting = []
      end

      def save_metadata(metadata)
        metadata[:id] = @backup_id
      end
    end
  end
end
