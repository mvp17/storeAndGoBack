module AuthorizeRequest
  extend ActiveSupport::Concern

  included do
    before_action :authorize_request
  end

  private

  def authorize_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    if token
      begin
        decoded = JsonWebToken.decode(token)
        puts "Decoded token: #{decoded.inspect}" # Debug statement
        if decoded && decoded[:user_id]
          @current_user = User.find(decoded[:user_id])
          puts "Current user: #{@current_user.inspect}" # Debug statement
        else
          render json: { errors: 'Invalid token' }, status: :unauthorized
        end
      rescue JWT::DecodeError => e
        puts "Decode Error: #{e.message}" # Debug statement
        render json: { errors: 'Unauthorized' }, status: :unauthorized
      rescue Cassandra::Errors::InvalidError => e
        puts "Cassandra Error: #{e.message}" # Debug statement
        render json: { errors: 'Unauthorized' }, status: :unauthorized
      end
    else
      render json: { errors: 'Missing token' }, status: :unauthorized
    end
  end
end
