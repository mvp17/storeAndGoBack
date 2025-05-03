# LAST TASKS MANAGER

class Shipment
    attr_accessor :id, :description, :containers, :origin_room, :destination_room
  
    def initialize(attributes = {})
      puts "Initializing with attributes: #{attributes.inspect}" # Debug logging
      @id = attributes[:id]
      @description = attributes[:description]
      @containers = attributes[:containers]
      @origin_room = attributes[:origin_room]
      @destination_room = attributes[:destination_room]
    end
  
    def as_json(options = {})
      {
        id: @id.to_s,
        description: @description,
        containers: @containers,
        origin_room: @origin_room,
        destination_room: @destination_room
      }
    end
  
    class << self
      def all
        results = CassandraClient.execute('SELECT * FROM rails.shipments')
        results.rows.map do |row|
          new(
            id: row['id'],
            description: row['description'],
            containers: JSON.parse(row['containers']),
            origin_room: JSON.parse(row['origin_room']),
            destination_room: JSON.parse(row['destination_room'])
          )
        end
      end
  
      def find(id)
        uuid = Cassandra::Uuid.new(id) # Convert string id to Cassandra::Uuid
        statement = CassandraClient.prepare('SELECT * FROM rails.shipments WHERE id = ?')
        result = CassandraClient.execute(statement, arguments: [uuid]).first
        puts "Raw result from Cassandra: #{result.inspect}" # Debug logging
        result ? new(id: result['id'], description: result['description'], containers: JSON.parse(result['containers']), origin_room: JSON.parse(result['origin_room']), destination_room: JSON.parse(result['destination_room'])) : nil
      end
  
      def create(attributes)
        id = Cassandra::Uuid.new(SecureRandom.uuid)
        statement = CassandraClient.prepare('INSERT INTO rails.shipments (id, description, containers, origin_room, destination_room) VALUES (?, ?, ?, ?, ?)')
        CassandraClient.execute(statement, arguments: [id, attributes[:description], attributes[:containers].to_json, attributes[:origin_room].to_json, attributes[:destination_room].to_json])
        new(id: id, description: attributes[:description], containers: attributes[:containers], origin_room: attributes[:origin_room], destination_room: attributes[:destination_room])
      end
  
      def update(id, attributes)
        uuid = Cassandra::Uuid.new(id) # Convert string id to Cassandra::Uuid
        statement = CassandraClient.prepare('UPDATE rails.shipments SET description = ?, containers = ?, origin_room = ?, destination_room = ? WHERE id = ?')
        CassandraClient.execute(statement, arguments: [attributes[:description], attributes[:containers].to_json, attributes[:origin_room].to_json, attributes[:destination_room].to_json, uuid])
        find(id) # Return the updated object
      end
  
      def destroy(id)
        uuid = Cassandra::Uuid.new(id) # Convert string id to Cassandra::Uuid
        statement = CassandraClient.prepare('DELETE FROM rails.shipments WHERE id = ?')
        CassandraClient.execute(statement, arguments: [uuid])
      end
    end
  end
  