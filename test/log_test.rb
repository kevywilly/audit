require 'test_helper'

class LogTest < Test::Unit::TestCase
  
  def setup
    Audit::Log.connection = Cassandra::Mock.new('Audit', storage_conf)
  end
  
  should "save audit record" do
    assert Audit::Log.record(:Users, 1, simple_change)
  end
  
  should "load audit records" do
    Audit::Log.record(:Users, 1, simple_change)
    assert_kind_of Audit::Changeset, Audit::Log.audits(:Users, 1).first
  end
  
  should "load audits with multiple changed attributes" do
    Audit::Log.record(:Users, 1, multiple_changes)
    changes = Audit::Log.audits(:Users, 1).first.changes
    changes.each do |change|
      assert %w{username age}.include?(change.attribute)
      assert ["akk", 30].include?(change.old_value)
      assert ["adam", 31].include?(change.new_value)
    end
  end
  
  def simple_change
    {"username" => ["akk", "adam"]}
  end
  
  def multiple_changes
    {"username" => ["akk", "adam"], "age" => [30, 31]}
  end
  
  def storage_conf
    File.join(File.dirname(__FILE__), 'storage-conf.xml')
  end
  
end
