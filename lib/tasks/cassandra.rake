namespace :cassandra do
  desc 'Create tables in Cassandra'
  task create_tables: :environment do
    keyspace = 'my_keyspace'
    table = 'entrance_manifests'
    
    statement = <<-CQL
      CREATE TABLE IF NOT EXISTS #{keyspace}.#{table} (
        id UUID PRIMARY KEY,
        reference TEXT,
        entrance_date TEXT,
        origin TEXT
      );
    CQL
    
    CassandraClient.execute(statement)
    puts "Table #{table} created successfully in keyspace #{keyspace}."
  end

  desc 'Drop tables in Cassandra'
  task drop_tables: :environment do
    keyspace = 'my_keyspace'
    table = 'entrance_manifests'
    
    statement = "DROP TABLE IF EXISTS #{keyspace}.#{table};"
    CassandraClient.execute(statement)
    puts "Table #{table} dropped successfully from keyspace #{keyspace}."
  end

  desc 'Reset Cassandra database by dropping and recreating tables'
  task reset: :environment do
    Rake::Task['cassandra:drop_tables'].invoke
    Rake::Task['cassandra:create_tables'].invoke
    puts 'Database reset successfully!'
  end
end

  