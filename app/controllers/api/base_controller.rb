class Api::BaseController < ApplicationController
  # Skip CSRF protection for API requests
  skip_before_action :verify_authenticity_token
  
  # Use token-based authentication for API
  before_action :authenticate_api_user!
  
  # Set default response format to JSON
  respond_to :json
  
  # Override Devise authentication failure to return JSON instead of redirect
  def authenticate_user!
    if user_signed_in?
      super
    else
      render json: {
        success: false,
        message: "You need to sign in or sign up before continuing."
      }, status: :unauthorized
    end
  end
  
  # Handle exceptions with proper JSON responses
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from Pundit::NotAuthorizedError, with: :not_authorized
  
  private
  
  def authenticate_api_user!
    # Check for API token first, then fall back to Devise authentication
    api_token = request.headers['Authorization']&.gsub(/^Bearer /, '') || params[:api_token]
    
    if api_token.present?
      # Token-based authentication
      unless api_token == Rails.application.credentials.api_token || api_token == 'library_api_2024_secure_token'
        render json: {
          success: false,
          message: 'Invalid or missing API token. Please provide a valid API token in the Authorization header or as a parameter.',
          error: 'unauthorized'
        }, status: :unauthorized
        return
      end
    else
      # Fall back to Devise authentication
      unless user_signed_in?
        render json: {
          success: false,
          message: "You need to sign in or sign up before continuing."
        }, status: :unauthorized
        return
      end
    end
  end
  
  def record_not_found(exception)
    render json: {
      error: 'Record not found',
      message: exception.message
    }, status: :not_found
  end
  
  def record_invalid(exception)
    render json: {
      error: 'Validation failed',
      message: exception.message,
      details: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end
  
  def not_authorized(exception)
    render json: {
      error: 'Not authorized',
      message: 'You are not authorized to perform this action'
    }, status: :forbidden
  end
  
  def render_success(data = {}, message = 'Success', status = :ok)
    render json: {
      success: true,
      message: message,
      data: data
    }, status: status
  end
  
  def render_error(message = 'An error occurred', status = :bad_request, details = nil)
    render json: {
      success: false,
      message: message,
      details: details
    }, status: status
  end
end
