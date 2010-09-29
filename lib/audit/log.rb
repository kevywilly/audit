require 'cassandra'
require 'active_support/core_ext/module'
require 'simple_uuid'
require 'yajl'

# Methods for manipulating audit data stored in Cassandra.
module Audit::Log
  
  # Public: set or fetch the connection to Cassandra that Audit will use.
  mattr_accessor :connection
  
  # Store an audit record.
  #
  # bucket - the String name for the logical bucket this audit record belongs 
  #          to (i.e. table)
  # key - the String key into the logical bucket
  # changes - the changes hash (as generated by ActiveRecord) to store
  #
  # Returns nothing.
  def self.record(bucket, key, changes)
    json = Yajl::Encoder.encode(changes)
    payload = {SimpleUUID::UUID.new => json}
    connection.insert(:Audits, "#{bucket}:#{key}", payload)
  end
  
  # Fetch all audits for a given record.
  #
  # bucket - the String name for the logical bucket this audit record belongs 
  #          to (i.e. table)
  # key - the String key into the logical bucket
  #
  # Returns an Array of Changeset objects
  def self.audits(bucket, key)
    # TODO: figure out how to do pagination here
    payload = connection.get(:Audits, "#{bucket}:#{key}", :reversed => true)
    payload.values.map do |p|
      Audit::Changeset.from_enumerable(Yajl::Parser.parse(p))
    end
  end
  
  # Clear all audit data. 
  # Note that this doesn't yet operate on logical 
  # buckets. _All_ of the audit data is destroyed. Proceed with caution.
  #
  # Returns nothing.
  def self.clear!
    # It'd be nice if this could clear one bucket at a time
    connection.clear_keyspace!
  end
  
end
