class Room
    attr_accessor :id, :room_status, :name, :temp, :hum, :quantity, :threshold
  
    def initialize(attributes = {})
        @id = attributes[:id]
        @room_status = attributes[:room_status]
        @name = attributes[:name]
        @temp = attributes[:temp]
        @hum = attributes[:hum]
        @quantity = attributes[:quantity]
        @threshold = attributes[:threshold]
    end
  
    def as_json(options = {})
        {
            id: @id.to_s,
            room_status: @room_status,
            name: @name,
            temp: @temp,
            hum: @hum,
            quantity: @quantity,
            threshold: @threshold
        }
    end
  
    class << self
        def all
            results = CassandraClient.execute('SELECT * FROM rails.rooms')
            results.rows.map do |row|
                new(
                    id: row['id'],
                    room_status: row['room_status'],
                    name: row['name'],
                    temp: row['temp'],
                    hum: row['hum'],
                    quantity: row['quantity'],
                    threshold: row['threshold']
                )
            end
        end
  
        def find(id)
            statement = CassandraClient.prepare('SELECT * FROM rails.rooms WHERE id = ?')            
            result = CassandraClient.execute(statement, arguments: [id]).first
            result ? new(id: result['id'], room_status: result['room_status'], name: result['name'], temp: result['temp'], hum: result['hum'], quantity: result['quantity'], threshold: result['threshold']) : nil
        end
  
        def create(attributes)
            id = Cassandra::Uuid.new(SecureRandom.uuid)
            statement = CassandraClient.prepare('INSERT INTO rails.rooms (id, room_status, name, temp, hum, quantity, threshold) VALUES (?, ?, ?, ?, ?, ?, ?)')
            CassandraClient.execute(statement, arguments: [id, attributes[:room_status], attributes[:name], attributes[:temp], attributes[:hum], attributes[:quantity], attributes[:threshold]])
            new(id: id, room_status: attributes[:room_status], name: attributes[:name], temp: attributes[:temp], hum: attributes[:hum], quantity: attributes[:quantity], threshold: attributes[:threshold])
        end
  
        def update(id, attributes)
            statement = CassandraClient.prepare('UPDATE rails.rooms SET room_status = ?, name = ?, temp = ?, hum = ?, quantity = ?, threshold = ? WHERE id = ?')
            CassandraClient.execute(statement, arguments: [attributes[:room_status], attributes[:name], attributes[:temp], attributes[:hum], attributes[:quantity], attributes[:threshold], id])
            find(id)
        end
  
        def destroy(id)
            statement = CassandraClient.prepare('DELETE FROM rails.rooms WHERE id = ?')
            CassandraClient.execute(statement, arguments: [id])
        end
    end
end
  