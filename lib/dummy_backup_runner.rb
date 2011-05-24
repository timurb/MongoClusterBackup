
require 'abstract_backup_runner'

module MongoBackup
  class DummyBackupRunner < AbstractBackupRunner
    def backup_node(node)
      if @opts[:backup_id]
        [ node, @opts[:backup_id] ]
      else
        node
      end
    end
    def update_waiting
      @waiting = []
    end
  end
end
