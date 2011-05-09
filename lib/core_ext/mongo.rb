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
  class Connection
    alias :unsafe_lock! :lock!
    alias :unsafe_unlock! :unlock!

    def lock!(*args)
      unsafe_lock!(*args) unless self.locked?
    end

    def unlock!(*args)
      begin
        unsafe_unlock!(*args)
      rescue => e
        e
      end
    end
  end

end
