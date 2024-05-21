class TechnicianTask
    attr_accessor :id, :type, :description, :room, :detail, :status, :date

    def initialize(attributes = {})
        @id = attributes[:id]
        @type = attributes[:type]
        @description = attributes[:description]
        @room = attributes[:room]
        @detail = attributes[:detail]
        @status = attributes[:status]
        @date = attributes[:date]
    end

    def as_json(options = {})
        {
        id: @id.to_s,
        type: @type,
        description: @description,
        room: @room,
        detail: @detail,
        status: @status,
        date: @date
        }
    end

    class << self
        def all
            results = CassandraClient.execute('SELECT * FROM my_keyspace.technician_tasks')
            results.rows.map do |row|
                new(
                id: row['id'],
                type: row['type'],
                description: row['description'],
                room: row['room'],
                detail: row['detail'],
                status: row['status'],
                date: row['date']
                )
            end
        end

        def find(id)
            uuid = Cassandra::Uuid.new(id)
            statement = CassandraClient.prepare('SELECT * FROM my_keyspace.technician_tasks WHERE id = ?')
            result = CassandraClient.execute(statement, arguments: [uuid]).first
            result ? new(id: result['id'], type: result['type'], description: result['description'], room: result['room'], detail: result['detail'], status: result['status'], date: result['date']) : nil
        end

        def create(attributes)
            id = Cassandra::Uuid.new(SecureRandom.uuid)
            statement = CassandraClient.prepare('INSERT INTO my_keyspace.technician_tasks (id, type, description, room, detail, status, date) VALUES (?, ?, ?, ?, ?, ?, ?)')
            CassandraClient.execute(statement, arguments: [id, attributes[:type], attributes[:description], attributes[:room], attributes[:detail], attributes[:status], attributes[:date]])
            new(id: id, type: attributes[:type], description: attributes[:description], room: attributes[:room], detail: attributes[:detail], status: attributes[:status], date: attributes[:date])
        end

        def update(id, attributes)
            uuid = Cassandra::Uuid.new(id)
            statement = CassandraClient.prepare('UPDATE my_keyspace.technician_tasks SET type = ?, description = ?, room = ?, detail = ?, status = ?, date = ? WHERE id = ?')
            CassandraClient.execute(statement, arguments: [attributes[:type], attributes[:description], attributes[:room], attributes[:detail], attributes[:status], attributes[:date], uuid])
            find(id)
        end

        def destroy(id)
            uuid = Cassandra::Uuid.new(id)
            statement = CassandraClient.prepare('DELETE FROM my_keyspace.technician_tasks WHERE id = ?')
            CassandraClient.execute(statement, arguments: [uuid])
        end
    end
end
  