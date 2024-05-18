class EntranceManifestsController < ApplicationController
  def index
    results = CassandraClient.execute('SELECT * FROM entrance_manifests')
    render json: results.rows
  end

  def show
  end

  def create
    statement = CassandraClient.prepare(
      'INSERT INTO entrance_manifests (id, ref, date, origin) VALUES (1, "ref 1", "18/05/2024", "origin 1")'
    )
    CassandraClient.execute(statement, arguments: [SecureRandom.uuid, params[:name]])
    render json: { message: 'Record created successfully' }, status: :created
  end

  def update
  end

  def destroy
  end
end
