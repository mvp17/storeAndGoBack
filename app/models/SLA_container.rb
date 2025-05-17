class SLAContainer
    attr_accessor :id, :product, :producer, :quantity, :min_temp, :max_temp, :min_hum, :max_hum, :date_limit
  
    def initialize(attributes = {})
      puts "Initializing SLA CONTAINER with: #{attributes.inspect}" # Debug logging
      @id = attributes[:id]
      @product = attributes[:product]
      @producer = attributes[:producer]
      @quantity = attributes[:quantity]
      @min_temp = attributes[:min_temp]
      @max_temp = attributes[:max_temp]
      @min_hum = attributes[:min_hum]
      @max_hum = attributes[:max_hum]
      @date_limit = attributes[:date_limit]
    end
  
    def as_json(options = {})
      {
        id: @id.to_s,
        product: @product,
        producer: @producer,
        quantity: @quantity,
        min_temp: @min_temp,
        max_temp: @max_temp,
        min_hum: @min_hum,
        max_hum: @max_hum,
        date_limit: @date_limit
      }
    end
  
    class << self
      def all
        results = CassandraClient.execute('SELECT * FROM rails.sla_containers')
        results.rows.map do |row|
          new(
            id: row['id'],
            product: row['product'], 
            producer: row['producer'],
            quantity: row['quantity'],
            min_temp: row['min_temp'], 
            max_temp: row['max_temp'], 
            min_hum: row['min_hum'], 
            max_hum: row['max_hum'], 
            date_limit: row['date_limit']
          )
        end
      end
  
      def find(id)
        statement = CassandraClient.prepare('SELECT * FROM rails.sla_containers WHERE id = ?')
        result = CassandraClient.execute(statement, arguments: [id]).first
        result ? new(
          id: result['id'],
          product: result['product'], 
          producer: result['producer'],
          quantity: result['quantity'],
          min_temp: result['min_temp'], 
          max_temp: result['max_temp'], 
          min_hum: result['min_hum'], 
          max_hum: result['max_hum'], 
          date_limit: result['date_limit']
        ) : nil
      end
  
      def create(attributes)
        id = Cassandra::Uuid.new(SecureRandom.uuid)
        statement = CassandraClient.prepare('INSERT INTO rails.sla_containers (id, product, producer, quantity, min_temp, max_temp, min_hum, max_hum, date_limit) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)')
        CassandraClient.execute(statement, arguments: [id, attributes[:product], attributes[:producer], attributes[:quantity], attributes[:min_temp], attributes[:max_temp], attributes[:min_hum], attributes[:max_hum], attributes[:date_limit]])
        new(
          id: id,
          product: attributes[:product], 
          producer: attributes[:producer],
          quantity: attributes[:quantity],
          min_temp: attributes[:min_temp], 
          max_temp: attributes[:max_temp], 
          min_hum: attributes[:min_hum], 
          max_hum: attributes[:max_hum], 
          date_limit: attributes[:date_limit]
        )
      end
  
      def update(id, attributes)
        statement = CassandraClient.prepare('UPDATE rails.sla_containers SET product = ?, producer = ?, quantity = ?, min_temp = ?, max_temp = ?, min_hum = ?, max_hum = ?, date_limit = ? WHERE id = ?')
        CassandraClient.execute(statement, arguments: [attributes[:product], attributes[:producer], attributes[:quantity], attributes[:min_temp], attributes[:max_temp], attributes[:min_hum], attributes[:max_hum], attributes[:date_limit], id])
        find(id)
      end
  
      def destroy(id)
        statement = CassandraClient.prepare('DELETE FROM rails.sla_containers WHERE id = ?')
        CassandraClient.execute(statement, arguments: [id])
      end
    end
end
