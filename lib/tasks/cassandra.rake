namespace :cassandra do
  desc 'Create tables in Cassandra'
  task create_tables: :environment do
    keyspace = 'my_keyspace'
    entrance_manifests_table = 'entrance_manifests'
    departure_manifests_table = 'departure_manifests'
    shipments_table = 'shipments'
    rooms_table = 'rooms'
    worker_tasks_table = 'worker_tasks'
    technician_tasks_table = 'technician_tasks'
    sla_containers_table = 'sla_containers'
    
    sla_containers_statement = <<-CQL
      CREATE TABLE IF NOT EXISTS #{keyspace}.#{sla_containers_table} (
        id UUID PRIMARY KEY,
        product_id INT,
        producer_id INT,
        quantity INT,
        sla TEXT,
        min_temp INT,
        max_temp INT,
        min_hum INT,
        max_hum INT,
        date_limit TEXT
      );
    CQL
    
    technician_tasks_statement = <<-CQL
      CREATE TABLE IF NOT EXISTS #{keyspace}.#{technician_tasks_table} (
        id UUID PRIMARY KEY,
        type INT,
        description TEXT,
        room TEXT,
        detail TEXT,
        status INT,
        date TEXT
      );
    CQL
    
    worker_tasks_statement = <<-CQL
      CREATE TABLE IF NOT EXISTS #{keyspace}.#{worker_tasks_table} (
        id UUID PRIMARY KEY,
        type INT,
        description TEXT,
        room TEXT,
        detail TEXT,
        status INT,
        date TEXT
      );
    CQL
    
    entrance_manifests_statement = <<-CQL
      CREATE TABLE IF NOT EXISTS #{keyspace}.#{entrance_manifests_table} (
        id UUID PRIMARY KEY,
        reference TEXT,
        entrance_date TEXT,
        origin TEXT
      );
    CQL

    departure_manifests_statement = <<-CQL
      CREATE TABLE IF NOT EXISTS #{keyspace}.#{departure_manifests_table} (
        id UUID PRIMARY KEY,
        reference TEXT,
        departure_date TEXT,
        destination TEXT
      );
    CQL

    shipments_statement = <<-CQL
      CREATE TABLE IF NOT EXISTS #{keyspace}.#{shipments_table} (
        id UUID PRIMARY KEY,
        description TEXT,
        containers TEXT,
        origin_room TEXT,
        destination_room TEXT
      );
    CQL

    rooms_statement = <<-CQL
      CREATE TABLE IF NOT EXISTS #{keyspace}.#{rooms_table} (
        id UUID PRIMARY KEY,
        room_status INT,
        pk INT,
        name TEXT,
        temp INT,
        hum INT,
        quantity INT,
        threshold INT
      );
    CQL
    
    CassandraClient.execute(entrance_manifests_statement)
    CassandraClient.execute(departure_manifests_statement)
    CassandraClient.execute(shipments_statement)
    CassandraClient.execute(rooms_statement)
    CassandraClient.execute(worker_tasks_statement)
    CassandraClient.execute(technician_tasks_statement)
    CassandraClient.execute(sla_containers_statement)
    
    puts "Tables #{entrance_manifests_table}, #{sla_containers_table}, #{technician_tasks_table}, #{worker_tasks_table}, #{rooms_table}, #{departure_manifests_table}, and #{shipments_table} created successfully in keyspace #{keyspace}."
  end

  desc 'Drop tables in Cassandra'
  task drop_tables: :environment do
    keyspace = 'my_keyspace'
    entrance_manifests_table = 'entrance_manifests'
    departure_manifests_table = 'departure_manifests'
    shipments_table = 'shipments'
    rooms_table = 'rooms'
    worker_tasks_table = 'worker_tasks'
    technician_tasks_table = 'technician_tasks'
    sla_containers_table = 'sla_containers'
    
    drop_entrance_manifests_statement = "DROP TABLE IF EXISTS #{keyspace}.#{entrance_manifests_table};"
    drop_departure_manifests_statement = "DROP TABLE IF EXISTS #{keyspace}.#{departure_manifests_table};"
    drop_shipments_statement = "DROP TABLE IF EXISTS #{keyspace}.#{shipments_table};"
    drop_rooms_statement = "DROP TABLE IF EXISTS #{keyspace}.#{rooms_table};"
    drop_worker_tasks_statement = "DROP TABLE IF EXISTS #{keyspace}.#{worker_tasks_table};"
    drop_technician_tasks_statement = "DROP TABLE IF EXISTS #{keyspace}.#{technician_tasks_table};"
    drop_sla_containers_statement = "DROP TABLE IF EXISTS #{keyspace}.#{sla_containers_table};"

    CassandraClient.execute(drop_entrance_manifests_statement)
    CassandraClient.execute(drop_departure_manifests_statement)
    CassandraClient.execute(drop_shipments_statement)
    CassandraClient.execute(drop_rooms_statement)
    CassandraClient.execute(drop_worker_tasks_statement)
    CassandraClient.execute(drop_technician_tasks_statement)
    CassandraClient.execute(drop_sla_containers_statement)
    
    puts "Tables #{entrance_manifests_table}, #{sla_containers_table}, #{technician_tasks_table}, #{worker_tasks_table}, #{rooms_table}, #{departure_manifests_table}, and #{shipments_table} dropped successfully from keyspace #{keyspace}."
  end

  desc 'Reset Cassandra database by dropping and recreating tables'
  task reset: :environment do
    Rake::Task['cassandra:drop_tables'].invoke
    Rake::Task['cassandra:create_tables'].invoke
    puts 'Database reset successfully!'
  end
end
