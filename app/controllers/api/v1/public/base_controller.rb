class Api::V1::Public::BaseController < ApplicationController
  # Skip CSRF protection for API requests
  skip_before_action :verify_authenticity_token
  
  # Skip Devise authentication (we'll use token authentication instead)
  skip_before_action :authenticate_user!
  
  # Token-based authentication for public API
  before_action :authenticate_api_token!
  
  # Set default response format to JSON
  respond_to :json
  
  # Handle exceptions with proper JSON responses
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  
  private
  
  def authenticate_api_token!
    # Fixed API token for external access
    api_token = request.headers['Authorization']&.gsub(/^Bearer /, '') || params[:api_token]
    
    # Check if token is provided and valid
    if api_token.blank?
      render json: {
        success: false,
        message: 'API token is required. Please provide a valid API token in the Authorization header (Bearer token) or as a parameter (api_token).',
        error: 'missing_token'
      }, status: :unauthorized
      return
    end
    
    unless api_token == 'library_api_2024_secure_token'
      render json: {
        success: false,
        message: 'Invalid API token. Please provide a valid API token.',
        error: 'invalid_token'
      }, status: :unauthorized
      return
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
