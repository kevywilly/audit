# Audit

Audit sits on top of your model objects and watches for changes to your data. When a change occurs, the differences are recorded and stored in Cassandra.

## Usage

Include `Audit::Tracking` into your change-sensitive ActiveRecord models. When you make changes to data in those tables, the relevant details will be written to a Cassandra column family.

## Example

    >> require 'audit'
    >> class User < ActiveRecord::Base; include Audit::Tracking; end
    >> u = User.create(:name => 'Adam', :city => 'Dallas')
    >> u.update_attributes(:city => 'Austin')
    >> u.audits
    [#<struct Audit::Changeset changes=[#<struct Audit::Change attribute="username", old="akk", new="therealadam">]>, #<struct Audit::Changeset changes=[#<struct Audit::Change attribute="username", old="adam", new="akk">]>, #<struct Audit::Changeset changes=[#<struct Audit::Change attribute="age", old=30, new=31>]>]

# Compatibility

Audit is tested against ActiveRecord 3.0, Ruby 1.8.7 and Ruby 1.9.2.

# Setup

For Cassandra 0.7, you can set up the schema with `cassandra-cli` like so:

    /* Create a new keyspace */
    create keyspace Audit with replication_factor = 1

    /* Switch to the new keyspace */
    use Audit

    /* Create new column families */
    create column family Audits with column_type = 'Standard' and comparator = 'TimeUUIDType' and rows_cached = 10000

For Cassandra 0.6, add the following to `storage-conf.xml`:

    <Keyspace Name="Audit">
        <KeysCachedFraction>0.01</KeysCachedFraction>
        <ColumnFamily CompareWith="TimeUUIDType" Name="Audits" />
        <ReplicaPlacementStrategy>org.apache.cassandra.locator.RackUnawareStrategy</ReplicaPlacementStrategy>
        <ReplicationFactor>1</ReplicationFactor>
        <EndPointSnitch>org.apache.cassandra.locator.EndPointSnitch</EndPointSnitch>
    </Keyspace>
    
## Hacking

Set up RVM:

    $ rvm install ree-1.8.7-2010.01
    $ rvm use ree-1.8.7-2010.01
    $ rvm gemset create audit
    $ rvm gemset use audit
    $ gem install bundler
    $ bundle install
    $ rvm install 1.9.2
    $ rvm use 1.9.2
    $ rvm gemset create audit
    $ rvm gemset use audit
    $ gem install bundler
    $ bundle install
    
Run the test suite with all supported runtimes:

    $ rvm 1.9.2@audit,ree-1.8.7-2010.01@audit rake test

## TODO

- Ignore changes on some attributes
- Add more AR callbacks (delete, ?)
- Generate bucket names for namespaced models

## License

Copyright 2010 Adam Keys `<adam@therealaadam.com>`

Audit is MIT licensed. Enjoy!
