class DepartureManifest
  attr_accessor :id, :reference, :departure_date, :destination

  def initialize(attributes = {})
    puts "Initializing with attributes: #{attributes.inspect}" # Debug logging
    @id = attributes[:id]
    @reference = attributes[:reference]
    @departure_date = attributes[:departure_date]
    @destination = attributes[:destination]
  end

  def as_json(options = {})
    {
      id: @id.to_s,
      reference: @reference,
      departure_date: @departure_date,
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
          destination: row['destination']
        )
      end
    end

    def find(id)
      statement = CassandraClient.prepare('SELECT * FROM rails.departure_manifests WHERE id = ?')
      result = CassandraClient.execute(statement, arguments: [id]).first
      puts "Raw result from Cassandra: #{result.inspect}" # Debug logging
      result ? new(id: result['id'], reference: result['reference'], departure_date: result['departure_date'], destination: result['destination']) : nil
    end

    def create(attributes)
      id = Cassandra::Uuid.new(SecureRandom.uuid)
      statement = CassandraClient.prepare('INSERT INTO rails.departure_manifests (id, reference, departure_date, destination) VALUES (?, ?, ?, ?)')
      CassandraClient.execute(statement, arguments: [id, attributes[:reference], attributes[:departure_date], attributes[:destination]])
      new(id: id, reference: attributes[:reference], departure_date: attributes[:departure_date], destination: attributes[:destination])
    end

    def update(id, attributes)
      statement = CassandraClient.prepare('UPDATE rails.departure_manifests SET reference = ?, departure_date = ?, destination = ? WHERE id = ?')
      CassandraClient.execute(statement, arguments: [attributes[:reference], attributes[:departure_date], attributes[:destination], id])
      find(id) # Return the updated object
    end

    def destroy(id)
      statement = CassandraClient.prepare('DELETE FROM rails.departure_manifests WHERE id = ?')
      CassandraClient.execute(statement, arguments: [id])
    end
  end
end
