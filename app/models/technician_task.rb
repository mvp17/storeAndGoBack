class TechnicianTask
    attr_accessor :id, :priority, :description, :room, :detail, :status, :date

    def initialize(attributes = {})
        puts "Initializing TECHNICIAN TASK with: #{attributes.inspect}" # Debug logging
        @id = attributes[:id]
        @priority = attributes[:priority]
        @description = attributes[:description]
        @room = attributes[:room]
        @detail = attributes[:detail]
        @status = attributes[:status]
        @date = attributes[:date]
    end

    def as_json(options = {})
        {
        id: @id.to_s,
        priority: @priority,
        description: @description,
        room: @room,
        detail: @detail,
        status: @status,
        date: @date
        }
    end

    class << self
        def all
            results = CassandraClient.execute('SELECT * FROM rails.technician_tasks')
            results.rows.map do |row|
                room_id = row['room']
                room = Room.find(room_id) if room_id

                new(
                id: row['id'],
                priority: row['priority'],
                description: row['description'],
                room: room,
                detail: row['detail'],
                status: row['status'],
                date: row['date']
                )
            end
        end

        def find(id)
            statement = CassandraClient.prepare('SELECT * FROM rails.technician_tasks WHERE id = ?')
            result = CassandraClient.execute(statement, arguments: [id]).first

            return nil unless result

            room_id = result['room']
            room = Room.find(room_id) if room_id

            new(id: result['id'], priority: result['priority'], description: result['description'], room: room, detail: result['detail'], status: result['status'], date: result['date'])
        end

        def create(attributes)
            id = Cassandra::Uuid.new(SecureRandom.uuid)
            room_uuid = attributes[:room] ? Cassandra::Uuid.new(attributes[:room]) : nil
            attributes[:room] = room_uuid
            statement = CassandraClient.prepare('INSERT INTO rails.technician_tasks (id, priority, description, room, detail, status, date) VALUES (?, ?, ?, ?, ?, ?, ?)')
            CassandraClient.execute(statement, arguments: [id, attributes[:priority], attributes[:description], attributes[:room], attributes[:detail], attributes[:status], attributes[:date]])
            new(id: id, priority: attributes[:priority], description: attributes[:description], room: attributes[:room], detail: attributes[:detail], status: attributes[:status], date: attributes[:date])
        end

        def update(id, attributes)
            room_uuid = attributes[:room] ? Cassandra::Uuid.new(attributes[:room]) : nil
            attributes[:room] = room_uuid
            statement = CassandraClient.prepare('UPDATE rails.technician_tasks SET priority = ?, description = ?, room = ?, detail = ?, status = ?, date = ? WHERE id = ?')
            CassandraClient.execute(statement, arguments: [attributes[:priority], attributes[:description], attributes[:room], attributes[:detail], attributes[:status], attributes[:date], id])
            find(id)
        end

        def destroy(id)
            statement = CassandraClient.prepare('DELETE FROM rails.technician_tasks WHERE id = ?')
            CassandraClient.execute(statement, arguments: [id])
        end
    end
end
