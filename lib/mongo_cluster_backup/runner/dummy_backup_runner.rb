
require 'mongo_cluster_backup/runner/abstract_backup_runner'

module MongoBackup
  class DummyBackupRunner < AbstractBackupRunner
    def backup_node(node)
      node
    end
    def update_waiting
      @waiting = []
    end
  end
end
