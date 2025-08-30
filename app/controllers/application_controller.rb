class ApplicationController < ActionController::API
  include Authenticable
  
  # Handle preflight OPTIONS requests
  before_action :handle_options_request
  
  private
  
  def handle_options_request
    if request.method == "OPTIONS"
      head :ok
    end
  end
end
