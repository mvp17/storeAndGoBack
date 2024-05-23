module AuthorizeRequest
    extend ActiveSupport::Concern
  
    included do
      before_action :authorize_request
    end
  
    private
  
    def authorize_request
      header = request.headers['Authorization']
      header = header.split(' ').last if header
      decoded = JsonWebToken.decode(header)
      @current_user = User.find(decoded[:user_id]) if decoded
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError
      render json: { errors: 'Unauthorized' }, status: :unauthorized
    end
  end
  