module Authenticable
  def authenticate_request!
    decoded_token = decoded_auth_token
    if decoded_token && decoded_token["user_id"]
      @current_user = User.find_by(id: decoded_token["user_id"])
    else
      render json: { error: "Not Authorized" }, status: :unauthorized
    end
  end

  private

  def authorization_header
    request.headers["Authorization"]
  end

  def decoded_auth_token
    if authorization_header
      @decoded_auth_token ||= decode_token(authorization_header.split(" ").last)
    end
  end

  def decode_token(token)
    begin
      decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
      decoded
    rescue JWT::DecodeError => e
      nil
    end
  end
end
