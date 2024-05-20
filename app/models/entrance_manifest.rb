class EntranceManifest
  attr_accessor :id, :reference, :entrance_date, :origin
    
  def initialize(attributes = {})
    puts "Initializing with attributes: #{attributes.inspect}" # Debug logging
    @id = attributes[:id]
    @reference = attributes[:reference]
    @entrance_date = attributes[:entrance_date]
    @origin = attributes[:origin]
  end

  def as_json(options = {})
    {
      id: @id.to_s,
      entrance_date: @entrance_date,
      origin: @origin,
      reference: @reference
    }
  end

  class << self
    # Fetch all records
    def all
      results = CassandraClient.execute('SELECT * FROM my_keyspace.entrance_manifests')
      puts "Cassandra Results: #{results.inspect}" # Debug logging
      results.rows.map do |row|
        new(
          id: row['id'],
          entrance_date: row['entrance_date'],
          origin: row['origin'],
          reference: row['reference']
        )
      end
    end

    # Find a record by ID
    def find(id)
      uuid = Cassandra::Uuid.new(id) # Convert string id to Cassandra::Uuid
      statement = CassandraClient.prepare('SELECT * FROM my_keyspace.entrance_manifests WHERE id = ?')
      result = CassandraClient.execute(statement, arguments: [uuid]).first
      puts "Raw result from Cassandra: #{result.inspect}" # Debug logging
      result ? new(id: result['id'], entrance_date: result['entrance_date'], origin: result['origin'], reference: result['reference']) : nil
    end

    # Create a new record
    def create(attributes)
      id = Cassandra::Uuid.new(SecureRandom.uuid) # Generate a new UUID
      statement = CassandraClient.prepare('INSERT INTO my_keyspace.entrance_manifests (id, reference, entrance_date, origin) VALUES (?, ?, ?, ?)')
      CassandraClient.execute(statement, arguments: [id, attributes[:reference], attributes[:entrance_date], attributes[:origin]])
      new(id: id, entrance_date: attributes[:entrance_date], origin: attributes[:origin], reference: attributes[:reference])
    end

    # Update a record by ID
    def update(id, attributes)
      uuid = Cassandra::Uuid.new(id) # Convert string id to Cassandra::Uuid
      statement = CassandraClient.prepare('UPDATE my_keyspace.entrance_manifests SET reference = ?, entrance_date = ?, origin = ? WHERE id = ?')
      CassandraClient.execute(statement, arguments: [attributes[:reference], attributes[:entrance_date], attributes[:origin], uuid])
      find(id)
    end

    # Delete a record by ID
    def destroy(id)
      uuid = Cassandra::Uuid.new(id) # Convert string id to Cassandra::Uuid
      statement = CassandraClient.prepare('DELETE FROM my_keyspace.entrance_manifests WHERE id = ?')
      CassandraClient.execute(statement, arguments: [uuid])
    end
    
    #timestamps
  end
end
