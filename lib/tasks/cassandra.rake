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
        product TEXT,
        producer TEXT,
        quantity INT,
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
        origin TEXT,
        containers TEXT,
      );
    CQL

    departure_manifests_statement = <<-CQL
      CREATE TABLE IF NOT EXISTS #{keyspace}.#{departure_manifests_table} (
        id UUID PRIMARY KEY,
        reference TEXT,
        departure_date TEXT,
        destination TEXT,
        containers TEXT,
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


  desc 'Seed SLA containers into Cassandra'
  task seed_sla_containers: :environment do
    keyspace = 'rails'
    sla_containers_table = 'sla_containers'

    # Sample seed data
    containers = [
      {
        product: "Lettuce",
        producer: "Farm A",
        quantity: 200,
        min_temp: 1,
        max_temp: 5,
        min_hum: 80,
        max_hum: 95,
        date_limit: "15-05-2025"
      },
      {
        product: "Tomatoes",
        producer: "Greenhouse B",
        quantity: 150,
        min_temp: 10,
        max_temp: 15,
        min_hum: 60,
        max_hum: 70,
        date_limit: "10-06-2025"
      },
      {
        product: "Cheese",
        producer: "Dairy Co",
        quantity: 50,
        min_temp: 2,
        max_temp: 4,
        min_hum: 65,
        max_hum: 75,
        date_limit: "01-07-2025"
      },
      {
        product: "Spinach",
        producer: "Organic Farms",
        quantity: 180,
        min_temp: 0,
        max_temp: 4,
        min_hum: 85,
        max_hum: 95,
        date_limit: "05-06-2025"
      },
      {
        product: "Strawberries",
        producer: "Berry Bros",
        quantity: 120,
        min_temp: 1,
        max_temp: 3,
        min_hum: 90,
        max_hum: 95,
        date_limit: "03-06-2025"
      },
      {
        product: "Yogurt",
        producer: "Dairy Co",
        quantity: 300,
        min_temp: 2,
        max_temp: 5,
        min_hum: 60,
        max_hum: 75,
        date_limit: "15-06-2025"
      },
      {
        product: "Apples",
        producer: "Orchard Fresh",
        quantity: 400,
        min_temp: 0,
        max_temp: 2,
        min_hum: 90,
        max_hum: 95,
        date_limit: "20-06-2025"
      },
      {
        product: "Carrots",
        producer: "Root Farms",
        quantity: 220,
        min_temp: 0,
        max_temp: 4,
        min_hum: 90,
        max_hum: 95,
        date_limit: "12-06-2025"
      },
      {
        product: "Ice Cream",
        producer: "Cool Treats Ltd",
        quantity: 100,
        min_temp: -20,
        max_temp: -18,
        min_hum: 50,
        max_hum: 70,
        date_limit: "30-08-2025"
      },
      {
        product: "Milk",
        producer: "Daily Dairy",
        quantity: 250,
        min_temp: 1,
        max_temp: 4,
        min_hum: 60,
        max_hum: 75,
        date_limit: "18-06-2025"
      },
      {
        product: "Broccoli",
        producer: "GreenHarvest",
        quantity: 160,
        min_temp: 0,
        max_temp: 2,
        min_hum: 85,
        max_hum: 95,
        date_limit: "07-06-2025"
      },
      {
        product: "Grapes",
        producer: "Vine Valley",
        quantity: 180,
        min_temp: 0,
        max_temp: 1,
        min_hum: 90,
        max_hum: 95,
        date_limit: "06-06-2025"
      },
      {
        product: "Butter",
        producer: "Golden Creamery",
        quantity: 90,
        min_temp: 1,
        max_temp: 5,
        min_hum: 60,
        max_hum: 70,
        date_limit: "22-06-2025"
      }
    ]

    insert_statement = CassandraClient.prepare(
      "INSERT INTO #{keyspace}.#{sla_containers_table} (id, product, producer, quantity, min_temp, max_temp, min_hum, max_hum, date_limit) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
    )

    containers.each do |container|
      id = Cassandra::Uuid.new(SecureRandom.uuid)
      begin
        CassandraClient.execute(
          insert_statement,
          arguments: [
            id,
            container[:product],
            container[:producer],
            container[:quantity],
            container[:min_temp],
            container[:max_temp],
            container[:min_hum],
            container[:max_hum],
            container[:date_limit]
          ]
        )
        puts "Inserted container with product #{container[:product]}"
      rescue => e
        puts "Failed to insert container #{container[:product]}: #{e.message}"
      end
    end

    puts "SLA containers inserted into #{keyspace}.#{sla_containers_table}"
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
      { name: "Sala F1",     room_status: 1, temp: 30, hum: 25, quantity: 10, threshold: 20 },
      { name: "Sala F2",     room_status: 1, temp: 31, hum: 15, quantity: 10, threshold: 20 },
      { name: "Sala F3",     room_status: 1, temp: 32, hum: 15, quantity: 10, threshold: 20 },
      { name: "Sala F4",     room_status: 1, temp: 25, hum: 15, quantity: 10, threshold: 20 },
      { name: "Sala F5",     room_status: 1, temp: 18, hum: 15, quantity: 10, threshold: 20 },
      { name: "Sala F6",     room_status: 1, temp: 10, hum: 15, quantity: 10, threshold: 20 },
      { name: "Moll carrega", room_status: 0, temp: nil, hum: nil, quantity: nil, threshold: nil }
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
    Rake::Task['cassandra:seed_sla_containers'].invoke
    puts 'Database reset and rooms and containers seeded successfully!'
  end
end
