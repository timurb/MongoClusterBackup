# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'mongo'

module Mongo

  class MongosConnection < ::Mongo::Connection
    def stop_balancer
      self['config']['settings'].update( { :_id => "balancer" }, { :stopped => true } )
    end

    def start_balancer
      self['config']['settings'].update( { :_id => "balancer" }, { :stopped => false } )
    end

    def shards
      self['admin'].command( { :listShards => 1} )["shards"]
    end
  end


  #     patching the Connection object's lock! and unlock! methods to be safe to run
  class SafeConnection < ::Mongo::Connection

    attr_reader :shard_name

    def initialize(*args)
      @shard_name = args.last.delete(:shard_name)  if args.last.is_a?( Hash )
      super(*args)
    end

    alias :unsafe_lock! :lock!
    alias :unsafe_unlock! :unlock!

    def lock!(*args)
      unsafe_lock!(*args) unless self.locked? # op hangs when locking already locked node
    end

    def unlock!(*args)
      begin
        unsafe_unlock!(*args)   # the failure in unlock op should not crash the whole program
      rescue => e
        e
      end
    end
  end

  class ReplSetConnection
    def passives
      @passives ||= self['local']['system.replset'].find_one()['members'].reject do |member|
        member["priority"] != 0
      end.map{ |m| m["host"] }
    end

    class << self
      def new_from_string(*args)
        replica = split_names( args.delete_at(0) )
        args = replica + args
        self.new(*args)
      end

      def split_names(replica)
        names = replica.match( /(([^\/]*)\/)?(([^:,]*)(:(\d+))?)(,([^:,]*)(:(\d+))?)?(,([^:,]*)(:(\d+))?)?(,([^:,]*)(:(\d+))?)?(,([^:,]*)(:(\d+))?)?(,([^:,]*)(:(\d+))?)?(,([^:,]*)(:(\d+))?)?/ ).to_a

        replset = []

        ((names.size+1)/4).times do |i|
          next if i==0
          host = names[i*4]
          port = names[i*4+2]
          port = port.to_i unless port.nil?
          next if host.nil? || host.empty?

          replset << [ host, port ]
        end

        replset << { :rs_name => names[2] }
      end
    end
  end
end
