class WorkerTask
  attr_accessor :id, :description, :containers, :origin_room, :destination_room, :status

  def initialize(attributes = {})
    puts "Initializing with attributes: #{attributes.inspect}" # Debug logging
    @id = attributes[:id]
    @description = attributes[:description]
    @containers = attributes[:containers]
    @origin_room = attributes[:origin_room]
    @destination_room = attributes[:destination_room]
    @status = attributes[:status]
  end

  def as_json(options = {})
    {
      id: @id.to_s,
      description: @description,
      containers: @containers,
      origin_room: @origin_room,
      destination_room: @destination_room,
      status: @status
    }
  end

  class << self
    def all
      results = CassandraClient.execute('SELECT * FROM my_keyspace.worker_tasks')
      results.rows.map do |row|
        new(
          id: row['id'],
          description: row['description'],
          containers: JSON.parse(row['containers']),
          origin_room: JSON.parse(row['origin_room']),
          destination_room: JSON.parse(row['destination_room']),
          status: row['status']
        )
      end
    end

    def find(id)
      uuid = Cassandra::Uuid.new(id) # Convert string id to Cassandra::Uuid
      statement = CassandraClient.prepare('SELECT * FROM my_keyspace.worker_tasks WHERE id = ?')
      result = CassandraClient.execute(statement, arguments: [uuid]).first
      puts "Raw result from Cassandra: #{result.inspect}" # Debug logging
      result ? new(
                id: result['id'], 
                description: result['description'], 
                containers: JSON.parse(result['containers']), 
                origin_room: JSON.parse(result['origin_room']), 
                destination_room: JSON.parse(result['destination_room']),
                status: result['status']) : nil
    end

    def create(attributes)
      id = Cassandra::Uuid.new(SecureRandom.uuid)
      statement = CassandraClient.prepare('INSERT INTO my_keyspace.worker_tasks (id, description, containers, origin_room, destination_room, status) VALUES (?, ?, ?, ?, ?, ?)')
      CassandraClient.execute(statement, arguments: [
                                                      id, 
                                                      attributes[:description], 
                                                      attributes[:containers].to_json, 
                                                      attributes[:origin_room].to_json, 
                                                      attributes[:destination_room].to_json,
                                                      attributes[:status]
                                                    ])
      new(
        id: id, 
        description: attributes[:description], 
        containers: attributes[:containers], 
        origin_room: attributes[:origin_room], 
        destination_room: attributes[:destination_room],
        status: attributes[:status])
    end

    def update(id, attributes)
      uuid = Cassandra::Uuid.new(id) # Convert string id to Cassandra::Uuid
      statement = CassandraClient.prepare('UPDATE my_keyspace.worker_tasks SET description = ?, status = ?, containers = ?, origin_room = ?, destination_room = ? WHERE id = ?')
      CassandraClient.execute(statement, arguments: [attributes[:description], attributes[:status], attributes[:containers].to_json, attributes[:origin_room].to_json, attributes[:destination_room].to_json, uuid])
      find(id) # Return the updated object
    end

    def destroy(id)
      uuid = Cassandra::Uuid.new(id) # Convert string id to Cassandra::Uuid
      statement = CassandraClient.prepare('DELETE FROM my_keyspace.worker_tasks WHERE id = ?')
      CassandraClient.execute(statement, arguments: [uuid])
    end
  end
end
