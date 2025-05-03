require 'sorted_set'
require 'cassandra'

CassandraClient = Cassandra.cluster(
  hosts: ['127.0.0.1'], # Update this to your Cassandra cluster IPs
  port: 9042,           # Default port for Cassandra
  username: 'cassandra', # If authentication is enabled
  password: 'cassandra'  # If authentication is enabled
).connect('rails') # Replace 'your_keyspace' with the keyspace you are using
