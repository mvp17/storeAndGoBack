# README

## Generate controller
rails generate controller folder_pathname index show create update destroy

## Generate model
rails g model entranceManifest reference:string entranceDate:string origin:string

## Gems
gem install gem_name
gem install cassandra-driver
bundle install

## Start server
bin/rails server
rails server

## DB migrations
bin/rails db:migrate

## Cassandra DB
cassandra -f
bundle exec rake cassandra:create_tables (File: lib/tasks/cassandra.rake)

$ cqlsh
Connected to your_cluster at 127.0.0.1:9042.
[cqlsh 5.0.1 | Cassandra 4.1.4 | CQL spec 3.4.5 | Native protocol v5]
Use HELP for help.
cqlsh> CREATE KEYSPACE my_new_keyspace
   ... WITH REPLICATION = {
   ...   'class' : 'SimpleStrategy',
   ...   'replication_factor' : 3
   ... };
cqlsh> DESCRIBE KEYSPACES;

system_schema  system  system_auth  system_distributed  system_traces  my_new_keyspace

cqlsh> USE my_new_keyspace;
cqlsh:my_new_keyspace> exit

