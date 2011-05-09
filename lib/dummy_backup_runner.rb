
require 'abstract_backup_runner'

module MongoBackup
  class DummyBackupRunner < AbstractBackupRunner
    def backup_node(node)
      node
    end
    def wait
      @waiting = []
    end
  end
end
