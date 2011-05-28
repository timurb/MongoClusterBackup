
module MongoBackup
  module BackupRunner
    class AbstractRunner

      attr_reader :backups
      attr_reader :waiting
      attr_reader :backup_id

      def initialize(nodes, opts={})
        @opts = {
          :wait => false,
        }.merge(opts)

        @backup_id = @opts.delete(:backup_id) || Time.now.to_i.to_s

        @nodes = nodes
        @backups = []
        @waiting = []
      end

      def run(opts={})
        opts = @opts.merge(opts)  # local options only

        @nodes.each do |node|
          if node=backup_node(node)
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
end
