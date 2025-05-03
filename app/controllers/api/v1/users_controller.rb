module Api
  module V1
    class UsersController < ApplicationController
      before_action :authorize_request, only: [:destroy, :index]

      def sign_up
        user = User.new(user_params)
        if user.save
          render json: user.as_json, status: :created
        else
          render json: { errors: 'Failed to create User' }, status: :unprocessable_entity
        end
      end

      def index
        users = User.all
        render json: users.map(&:as_json), status: :ok
      end

      def sign_in
        user = User.find_by_username(params[:username])
        if user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: user.id)
          render json: { token: token, user: user.as_json }, status: :ok
        else
          render json: { errors: 'Invalid username or password' }, status: :unauthorized
        end
      end

      def destroy
        user = User.find(params[:id])
        if user
          User.destroy(user.id)
          render json: { message: 'User deleted' }, status: :ok
        else
          render json: { errors: 'Unauthorized or user not found' }, status: :unauthorized
        end
      end

      private

      def user_params
        params.require(:user).permit(:username, :first_name, :last_name, :email, :password)
      end

      def authorize_request
        header = request.headers['Authorization']
        header = header.split(' ').last if header
        decoded = JsonWebToken.decode(header)
        @current_user_id = decoded[:user_id]
      rescue
        render json: { errors: 'Unauthorized' }, status: :unauthorized
      end
    end
  end
end
  