class EntranceManifest
    attr_accessor :id, :reference, :entrance_date, :origin
    
    def initialize(attributes = {})
        @id = attributes[:id]
        @reference = attributes[:reference]
        @entrance_date = attributes[:entrance_date]
        @origin = attributes[:origin]
    end

    # Fetch all records
  def self.all
    results = CassandraClient.execute('SELECT * FROM my_keyspace.entrance_manifests')
    results
  end

  # Find a record by ID
  def self.find(id)
    statement = CassandraClient.prepare('SELECT * FROM my_keyspace.entrance_manifests WHERE id = ?')
    result = CassandraClient.execute(statement, arguments: [id]).first
    result ? new(result) : nil
  end

  # Create a new record
  def self.create(attributes)
    statement = CassandraClient.prepare('INSERT INTO my_keyspace.entrance_manifests (id, reference, entrance_date, origin) VALUES (?, ?, ?, ?)')
    CassandraClient.execute(statement, arguments: [Cassandra::Uuid.new(SecureRandom.uuid), attributes[:ref], attributes[:date], attributes[:origin]])
  end

  # Update a record by ID
  def self.update(id, attributes)
    statement = CassandraClient.prepare('UPDATE my_keyspace.entrance_manifests SET reference = ?, entrance_date = ?, origin = ? WHERE id = ?')
    CassandraClient.execute(statement, arguments: [attributes[:ref], attributes[:date], attributes[:origin], id])
  end

  # Delete a record by ID
  def self.destroy(id)
    statement = CassandraClient.prepare('DELETE FROM my_keyspace.entrance_manifests WHERE id = ?')
    CassandraClient.execute(statement, arguments: [id])
  end
    
    #timestamps
end
