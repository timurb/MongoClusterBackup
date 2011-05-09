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
end
