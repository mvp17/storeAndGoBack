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
      results = CassandraClient.execute('SELECT * FROM rails.worker_tasks')
      results.rows.map do |row|
        origin_room_id = row['origin_room']
        destination_room_id = row['destination_room']
        origin_room = Room.find(origin_room_id) if origin_room_id
        destination_room = Room.find(destination_room_id) if destination_room_id

        new(
          id: row['id'],
          description: row['description'],
          containers: JSON.parse(row['containers']),
          origin_room: origin_room,
          destination_room: destination_room,
          status: row['status']
        )
      end
    end

    def find(id)
      uuid = Cassandra::Uuid.new(id) # Convert string id to Cassandra::Uuid
      statement = CassandraClient.prepare('SELECT * FROM rails.worker_tasks WHERE id = ?')
      result = CassandraClient.execute(statement, arguments: [uuid]).first

      puts "Raw result from Cassandra: #{result.inspect}" # Debug logging

      return nil unless result

      origin_room_id = result['origin_room']
      destination_room_id = result['destination_room']
      origin_room = Room.find(origin_room_id) if origin_room_id
      destination_room = Room.find(destination_room_id) if destination_room_id

      new(
        id: result['id'], 
        description: result['description'], 
        containers: JSON.parse(result['containers']), 
        origin_room: origin_room, 
        destination_room: destination_room,
        status: result['status']
      )
    end

    def create(attributes)
      id = Cassandra::Uuid.new(SecureRandom.uuid)
      origin_room_uuid = attributes[:origin_room] ? Cassandra::Uuid.new(attributes[:origin_room]) : nil
      destination_room_uuid = attributes[:destination_room] ? Cassandra::Uuid.new(attributes[:destination_room]) : nil
      attributes[:origin_room] = origin_room_uuid
      attributes[:destination_room] = destination_room_uuid
      statement = CassandraClient.prepare('INSERT INTO rails.worker_tasks (id, description, containers, origin_room, destination_room, status) VALUES (?, ?, ?, ?, ?, ?)')
      CassandraClient.execute(statement, arguments: [
                                                      id, 
                                                      attributes[:description], 
                                                      attributes[:containers].to_json, 
                                                      attributes[:origin_room], 
                                                      attributes[:destination_room],
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
      statement = CassandraClient.prepare('UPDATE rails.worker_tasks SET description = ?, status = ?, containers = ?, origin_room = ?, destination_room = ? WHERE id = ?')
      CassandraClient.execute(statement, arguments: [attributes[:description], attributes[:status], attributes[:containers].to_json, attributes[:origin_room], attributes[:destination_room], uuid])
      find(id) # Return the updated object
    end

    def destroy(id)
      uuid = Cassandra::Uuid.new(id) # Convert string id to Cassandra::Uuid
      statement = CassandraClient.prepare('DELETE FROM rails.worker_tasks WHERE id = ?')
      CassandraClient.execute(statement, arguments: [uuid])
    end
  end
end
