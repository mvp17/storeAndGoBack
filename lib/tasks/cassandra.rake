namespace :cassandra do
  desc 'Create tables in Cassandra'
  task create_tables: :environment do
    keyspace = 'rails'
    entrance_manifests_table = 'entrance_manifests'
    departure_manifests_table = 'departure_manifests'
    shipments_table = 'shipments'
    rooms_table = 'rooms'
    worker_tasks_table = 'worker_tasks'
    technician_tasks_table = 'technician_tasks'
    sla_containers_table = 'sla_containers'
    users_table = 'users'
    
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
        priority INT,
        description TEXT,
        room UUID,
        detail TEXT,
        status INT,
        date TEXT
      );
    CQL
    
    worker_tasks_statement = <<-CQL
      CREATE TABLE IF NOT EXISTS #{keyspace}.#{worker_tasks_table} (
        id UUID PRIMARY KEY,
        description TEXT,
        containers TEXT,
        origin_room UUID,
        destination_room UUID,
        status INT
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
        origin_room UUID,
        destination_room UUID
      );
    CQL

    rooms_statement = <<-CQL
      CREATE TABLE IF NOT EXISTS #{keyspace}.#{rooms_table} (
        id UUID PRIMARY KEY,
        room_status INT,
        name TEXT,
        temp INT,
        hum INT,
        quantity INT,
        threshold INT
      );
    CQL

    users_statement = <<-CQL
      CREATE TABLE IF NOT EXISTS #{keyspace}.#{users_table} (
        id UUID PRIMARY KEY,
        username TEXT,
        first_name TEXT,
        last_name TEXT,
        email TEXT,
        password_hash TEXT
      );
    CQL
    
    [
      entrance_manifests_statement, 
      departure_manifests_statement, 
      rooms_statement, 
      shipments_statement,
      worker_tasks_statement, 
      technician_tasks_statement, 
      sla_containers_statement, 
      users_statement
    ].each do |statement|
      CassandraClient.execute(statement)
    end
    
    puts "Tables #{entrance_manifests_table}, #{users_table}, #{sla_containers_table}, #{technician_tasks_table}, #{worker_tasks_table}, #{rooms_table}, #{departure_manifests_table}, and #{shipments_table} created successfully in keyspace #{keyspace}."
  end

  desc 'Drop tables in Cassandra'
  task drop_tables: :environment do
    keyspace = 'rails'
    tables = %w[entrance_manifests users departure_manifests shipments rooms worker_tasks technician_tasks sla_containers]
    
    tables.each do |table|
      statement = "DROP TABLE IF EXISTS #{keyspace}.#{table};"
      CassandraClient.execute(statement)
      puts "Table #{table} dropped successfully from keyspace #{keyspace}."
    end
  end

  desc 'Seed rooms into Cassandra'
  task seed_rooms: :environment do
    keyspace = 'rails'
    rooms_table = 'rooms'
    rooms = [
      { name: "Sala 1",      room_status: 0, temp: 20, hum: 15, quantity: 10, threshold: 20 },
      { name: "Sala 2",      room_status: 1, temp: 21, hum: 16, quantity: 10, threshold: 20 },
      { name: "Sala A",      room_status: 1, temp: -22, hum: 17, quantity: 10, threshold: 20 },
      { name: "Sala B",      room_status: 1, temp: 23, hum: 18, quantity: 10, threshold: 20 },
      { name: "Sala C",      room_status: 1, temp: -24, hum: 19, quantity: 10, threshold: 20 },
      { name: "Sala M1",     room_status: 1, temp: 25, hum: 20, quantity: 10, threshold: 20 },
      { name: "Sala M2",     room_status: 1, temp: -26, hum: 21, quantity: 10, threshold: 20 },
      { name: "Sala M3",     room_status: 1, temp: 27, hum: 22, quantity: 10, threshold: 20 },
      { name: "Sala F7",     room_status: 1, temp: 28, hum: 23, quantity: 10, threshold: 20 },
      { name: "Sala F7",     room_status: 1, temp: -29, hum: 24, quantity: 10, threshold: 20 },
      { name: "Sala F1",     room_status: 1, temp: 30, hum: 25, quantity: 10, threshold: 20 },
      { name: "Sala F2",     room_status: 1, temp: 31, hum: 15, quantity: 10, threshold: 20 },
      { name: "Sala F3",     room_status: 1, temp: 32, hum: 15, quantity: 10, threshold: 20 },
      { name: "Sala F4",     room_status: 1, temp: 25, hum: 15, quantity: 10, threshold: 20 },
      { name: "Sala F5",     room_status: 1, temp: 18, hum: 15, quantity: 10, threshold: 20 },
      { name: "Sala F6",     room_status: 1, temp: 10, hum: 15, quantity: 10, threshold: 20 },
      { name: "Moll càrrega", room_status: 0, temp: nil, hum: nil, quantity: nil, threshold: nil }
    ]

    statement = CassandraClient.prepare('INSERT INTO rails.rooms (id, room_status, name, temp, hum, quantity, threshold)
      VALUES (?, ?, ?, ?, ?, ?, ?)')
    
    rooms.each do |room|
      id = Cassandra::Uuid.new(SecureRandom.uuid)
      
      begin
        CassandraClient.execute(
          statement,
          arguments: [
            id,
            room[:room_status],
            room[:name],
            room[:temp],
            room[:hum],
            room[:quantity],
            room[:threshold]
          ]
        )
        puts "Inserted room #{room[:name]}"
      rescue => e
        puts "Failed to insert room #{room[:name]}: #{e.message}"
      end
    end

    puts "Rooms inserted into #{keyspace}.#{rooms_table}"
  end

  desc 'Reset Cassandra database by dropping and recreating tables'
  task reset: :environment do
    Rake::Task['cassandra:drop_tables'].invoke
    Rake::Task['cassandra:create_tables'].invoke
    Rake::Task['cassandra:seed_rooms'].invoke
    puts 'Database reset and rooms seeded successfully!'
  end
end
