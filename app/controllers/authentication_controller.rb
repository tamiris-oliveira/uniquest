class AuthenticationController < ApplicationController
  def login
    @user = User.find_by(email: params[:email])

    if @user && @user.authenticate(params[:password])
      token = encode_token({ user_id: @user.id, role: @user.role })
      render json: { token: token, user: @user }, status: :ok
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end

  def encode_token(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end

  def decode_token(token)
    begin
      JWT.decode(token, Rails.application.secret_key_base)[0]
    rescue JWT::DecodeError
      nil
    end
  end
end
