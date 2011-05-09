
module MongoBackup
  class AbstractBackupRunner

    attr_reader :backups
    attr_reader :waiting

    def initialize(nodes, opts={})
      @opts = {
        :wait => false,
      }.merge(opts)

      @nodes = nodes
      @backups = []
      @waiting = []
    end

    def run(opts={})
      opts = @opts.merge(opts)  # local options only
      
      @nodes.each do |node|
        if backup_node(node)
          @backups << node
          @waiting << node if opts[:wait]
        end
      end
    end

    def update_waiting
      raise "Procedure not implemented"
    end

    def backup_node(*args)
      raise "Procedure not implemented"
    end
  end
end
