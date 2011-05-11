
require 'abstract_backup_runner'

module MongoBackup
  class MongoDumpBackupRunner < AbstractBackupRunner

    def backup_node(node)
      system( 'mongodump', '-o', node.shard_name, '-h', node.host, '--port', node.port.to_s )
    end
    def update_waiting
      @waiting = []
    end

  end
end
