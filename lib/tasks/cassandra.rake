namespace :cassandra do
    desc 'Create tables in Cassandra'
    task create_tables: :environment do
      keyspace = 'my_keyspace'
      table = 'entrance_manifests'
      
      statement = <<-CQL
        CREATE TABLE IF NOT EXISTS #{keyspace}.#{table} (
          id UUID PRIMARY KEY,
          ref TEXT,
          date TEXT,
          origin TEXT
        );
      CQL
      
      CassandraClient.execute(statement)
      puts "Table #{table} created successfully in keyspace #{keyspace}."
    end
  end
  