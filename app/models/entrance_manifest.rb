class EntranceManifest
  attr_accessor :id, :reference, :entrance_date, :origin
    
  def initialize(attributes = {})
    puts "Initializing ENTRANCE MANIFEST with: #{attributes.inspect}" # Debug logging
    @id = attributes[:id]
    @reference = attributes[:reference]
    @entrance_date = attributes[:entrance_date]
    @origin = attributes[:origin]
    @containers = attributes[:containers]
  end

  def as_json(options = {})
    {
      id: @id.to_s,
      entrance_date: @entrance_date,
      origin: @origin,
      containers: @containers,
      reference: @reference
    }
  end

  class << self
    # Fetch all records
    def all
      results = CassandraClient.execute('SELECT * FROM rails.entrance_manifests')
      puts "Cassandra Results: #{results.inspect}" # Debug logging
      results.rows.map do |row|
        new(
          id: row['id'],
          entrance_date: row['entrance_date'],
          containers: JSON.parse(row['containers']),
          origin: row['origin'],
          reference: row['reference']
        )
      end
    end

    # Find a record by ID
    def find(id)
      statement = CassandraClient.prepare('SELECT * FROM rails.entrance_manifests WHERE id = ?')
      result = CassandraClient.execute(statement, arguments: [id]).first

      puts "Raw result from Cassandra: #{result.inspect}" # Debug logging
      
      return nil unless result

      new(
        id: result['id'], 
        entrance_date: result['entrance_date'], 
        origin: result['origin'],
        containers: JSON.parse(result['containers']),
        reference: result['reference']
        )
    end

    # Create a new record
    def create(attributes)
      id = Cassandra::Uuid.new(SecureRandom.uuid) # Generate a new UUID
      statement = CassandraClient.prepare('INSERT INTO rails.entrance_manifests (id, reference, entrance_date, origin, containers) VALUES (?, ?, ?, ?, ?)')
      CassandraClient.execute(statement, arguments: [id, attributes[:reference], attributes[:entrance_date], attributes[:origin], attributes[:containers].to_json])
      new(id: id, entrance_date: attributes[:entrance_date], origin: attributes[:origin], reference: attributes[:reference], containers: attributes[:containers])
    end

    # Update a record by ID
    def update(id, attributes)
      statement = CassandraClient.prepare('UPDATE rails.entrance_manifests SET reference = ?, entrance_date = ?, origin = ?, containers = ? WHERE id = ?')
      CassandraClient.execute(statement, arguments: [attributes[:reference], attributes[:entrance_date], attributes[:origin], attributes[:containers].to_json, id])
      find(id)
    end

    # Delete a record by ID
    def destroy(id)
      statement = CassandraClient.prepare('DELETE FROM rails.entrance_manifests WHERE id = ?')
      CassandraClient.execute(statement, arguments: [id])
    end
    
    #timestamps
  end
end
