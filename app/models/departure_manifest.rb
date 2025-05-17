class DepartureManifest
  attr_accessor :id, :reference, :departure_date, :destination

  def initialize(attributes = {})
    puts "Initializing DEPARTURE MANIFEST with: #{attributes.inspect}" # Debug logging
    @id = attributes[:id]
    @reference = attributes[:reference]
    @departure_date = attributes[:departure_date]
    @destination = attributes[:destination]
    @containers = attributes[:containers]
  end

  def as_json(options = {})
    {
      id: @id.to_s,
      reference: @reference,
      departure_date: @departure_date,
      containers: @containers,
      destination: @destination
    }
  end

  class << self
    def all
      results = CassandraClient.execute('SELECT * FROM rails.departure_manifests')
      results.rows.map do |row|
        new(
          id: row['id'],
          reference: row['reference'],
          departure_date: row['departure_date'],
          containers: JSON.parse(row['containers']),
          destination: row['destination']
        )
      end
    end

    def find(id)
      statement = CassandraClient.prepare('SELECT * FROM rails.departure_manifests WHERE id = ?')
      result = CassandraClient.execute(statement, arguments: [id]).first
      
      puts "Raw result from Cassandra: #{result.inspect}" # Debug logging

      return nil unless result

      new(
        id: result['id'], 
        reference: result['reference'], 
        departure_date: result['departure_date'],
        containers: JSON.parse(result['containers']),
        destination: result['destination']
        )
    end

    def create(attributes)
      id = Cassandra::Uuid.new(SecureRandom.uuid)
      statement = CassandraClient.prepare('INSERT INTO rails.departure_manifests (id, reference, departure_date, destination, containers) VALUES (?, ?, ?, ?, ?)')
      CassandraClient.execute(statement, arguments: [id, attributes[:reference], attributes[:departure_date], attributes[:destination], attributes[:containers].to_json])
      new(id: id, reference: attributes[:reference], departure_date: attributes[:departure_date], destination: attributes[:destination], containers: attributes[:containers])
    end

    def update(id, attributes)
      statement = CassandraClient.prepare('UPDATE rails.departure_manifests SET reference = ?, departure_date = ?, destination = ?, containers = ? WHERE id = ?')
      CassandraClient.execute(statement, arguments: [attributes[:reference], attributes[:departure_date], attributes[:destination], attributes[:containers].to_json, id])
      find(id) # Return the updated object
    end

    def destroy(id)
      statement = CassandraClient.prepare('DELETE FROM rails.departure_manifests WHERE id = ?')
      CassandraClient.execute(statement, arguments: [id])
    end
  end
end
