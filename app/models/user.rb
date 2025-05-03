require 'bcrypt'

class User
  include ActiveModel::Model
  include BCrypt

  attr_accessor :id, :username, :first_name, :last_name, :email, :password_hash

  def initialize(attributes = {})
    @id = attributes[:id] || Cassandra::Uuid.new(SecureRandom.uuid)
    @username = attributes[:username]
    @first_name = attributes[:first_name]
    @last_name = attributes[:last_name]
    @email = attributes[:email]
    @password_hash = attributes[:password_hash] || Password.create(attributes[:password])
  end

  def self.all
    results = CassandraClient.execute('SELECT * FROM rails.users')
    results.rows.map { |row| new(parse_row(row)) }
  end

  def self.find_by_username(username)
    result = CassandraClient.execute('SELECT * FROM rails.users WHERE username = ? ALLOW FILTERING', arguments: [username]).first
    new(parse_row(result)) if result
  end

  def self.find_by_email(email)
    result = CassandraClient.execute('SELECT * FROM rails.users WHERE email = ? ALLOW FILTERING', arguments: [email]).first
    new(parse_row(result)) if result
  end

  def self.find(id)
    uuid = Cassandra::Uuid.new(id)
    result = CassandraClient.execute('SELECT * FROM rails.users WHERE id = ?', arguments: [uuid]).first
    new(parse_row(result)) if result
  end

  def save
    statement = <<-CQL
      INSERT INTO rails.users (id, username, first_name, last_name, email, password_hash)
      VALUES (?, ?, ?, ?, ?, ?)
    CQL
    CassandraClient.execute(statement, arguments: [id, username, first_name, last_name, email, password_hash])
  end

  def update(attributes = {})
    @username = attributes[:username] if attributes[:username]
    @first_name = attributes[:first_name] if attributes[:first_name]
    @last_name = attributes[:last_name] if attributes[:last_name]
    @email = attributes[:email] if attributes[:email]
    @password_hash = Password.create(attributes[:password]) if attributes[:password]

    save
  end

  def self.destroy(id)
    #uuid = Cassandra::Uuid.new(id)
    statement = CassandraClient.prepare('DELETE FROM rails.users WHERE id = ?')
    CassandraClient.execute(statement, arguments: [id])
  end

  def as_json(options = {})
    {
      id: id.to_s,
      username: username,
      first_name: first_name,
      last_name: last_name,
      email: email
    }
  end

  def authenticate(password)
    Password.new(password_hash) == password
  end

  private

  def self.parse_row(row)
    {
      id: row['id'],
      username: row['username'],
      first_name: row['first_name'],
      last_name: row['last_name'],
      email: row['email'],
      password_hash: row['password_hash']
    }
  end
end
