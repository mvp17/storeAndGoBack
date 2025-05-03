class SLAContainer
    attr_accessor :id, :product_id, :producer_id, :quantity, :sla, :min_temp, :max_temp, :min_hum, :max_hum, :date_limit
  
    def initialize(attributes = {})
      @id = attributes[:id]
      @product_id = attributes[:product][:productId]
      @producer_id = attributes[:product][:producerId]
      @quantity = attributes[:quantity]
      @sla = attributes[:sla][:SLA]
      @min_temp = attributes[:sla][:minTemp]
      @max_temp = attributes[:sla][:maxTemp]
      @min_hum = attributes[:sla][:minHum]
      @max_hum = attributes[:sla][:maxHum]
      @date_limit = attributes[:sla][:date_limit]
    end
  
    def as_json(options = {})
      {
        id: @id.to_s,
        product: {
          productId: @product_id,
          producerId: @producer_id
        },
        quantity: @quantity,
        sla: {
          SLA: @sla,
          minTemp: @min_temp,
          maxTemp: @max_temp,
          minHum: @min_hum,
          maxHum: @max_hum,
          date_limit: @date_limit
        }
      }
    end
  
    class << self
      def all
        results = CassandraClient.execute('SELECT * FROM rails.sla_containers')
        results.rows.map do |row|
          new(
            id: row['id'],
            product: { productId: row['product_id'], producerId: row['producer_id'] },
            quantity: row['quantity'],
            sla: { SLA: row['sla'], minTemp: row['min_temp'], maxTemp: row['max_temp'], minHum: row['min_hum'], maxHum: row['max_hum'], date_limit: row['date_limit'] }
          )
        end
      end
  
      def find(id)
        uuid = Cassandra::Uuid.new(id)
        statement = CassandraClient.prepare('SELECT * FROM rails.sla_containers WHERE id = ?')
        result = CassandraClient.execute(statement, arguments: [uuid]).first
        result ? new(
          id: result['id'],
          product: { productId: result['product_id'], producerId: result['producer_id'] },
          quantity: result['quantity'],
          sla: { SLA: result['sla'], minTemp: result['min_temp'], maxTemp: result['max_temp'], minHum: result['min_hum'], maxHum: result['max_hum'], date_limit: result['date_limit'] }
        ) : nil
      end
  
      def create(attributes)
        id = Cassandra::Uuid.new(SecureRandom.uuid)
        statement = CassandraClient.prepare('INSERT INTO rails.sla_containers (id, product_id, producer_id, quantity, sla, min_temp, max_temp, min_hum, max_hum, date_limit) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)')
        CassandraClient.execute(statement, arguments: [id, attributes[:product][:productId], attributes[:product][:producerId], attributes[:quantity], attributes[:sla][:SLA], attributes[:sla][:minTemp], attributes[:sla][:maxTemp], attributes[:sla][:minHum], attributes[:sla][:maxHum], attributes[:sla][:date_limit]])
        new(
          id: id,
          product: { productId: attributes[:product][:productId], producerId: attributes[:product][:producerId] },
          quantity: attributes[:quantity],
          sla: { SLA: attributes[:sla][:SLA], minTemp: attributes[:sla][:minTemp], maxTemp: attributes[:sla][:maxTemp], minHum: attributes[:sla][:minHum], maxHum: attributes[:sla][:maxHum], date_limit: attributes[:sla][:date_limit] }
        )
      end
  
      def update(id, attributes)
        uuid = Cassandra::Uuid.new(id)
        statement = CassandraClient.prepare('UPDATE rails.sla_containers SET product_id = ?, producer_id = ?, quantity = ?, sla = ?, min_temp = ?, max_temp = ?, min_hum = ?, max_hum = ?, date_limit = ? WHERE id = ?')
        CassandraClient.execute(statement, arguments: [attributes[:product][:productId], attributes[:product][:producerId], attributes[:quantity], attributes[:sla][:SLA], attributes[:sla][:minTemp], attributes[:sla][:maxTemp], attributes[:sla][:minHum], attributes[:sla][:maxHum], attributes[:sla][:date_limit], uuid])
        find(id)
      end
  
      def destroy(id)
        uuid = Cassandra::Uuid.new(id)
        statement = CassandraClient.prepare('DELETE FROM rails.sla_containers WHERE id = ?')
        CassandraClient.execute(statement, arguments: [uuid])
      end
    end
  end