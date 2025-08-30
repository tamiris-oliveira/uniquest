module Authenticable
  def authenticate_request!
    begin
      decoded_token = decoded_auth_token
      if decoded_token && decoded_token["user_id"]
        @current_user = User.find_by(id: decoded_token["user_id"])
        unless @current_user
          render json: { error: "User not found" }, status: :unauthorized
          return
        end
        
        # Verificar se o usuário pode acessar o sistema
        unless @current_user.can_access_system?
          status_message = case @current_user.approval_status
          when 'pending'
            'Sua conta está aguardando aprovação de um administrador'
          when 'rejected'
            'Sua conta foi rejeitada. Entre em contato com o suporte'
          when 'suspended'
            'Sua conta foi suspensa. Entre em contato com o suporte'
          else
            'Acesso negado'
          end
          
          render json: { 
            error: "Access denied", 
            message: status_message,
            approval_status: @current_user.approval_status 
          }, status: :forbidden
          return
        end
      else
        render json: { error: "Not Authorized" }, status: :unauthorized
        return
      end
    rescue => e
      Rails.logger.error "Erro na autenticação: #{e.message}"
      render json: { error: "Authentication error", details: e.message }, status: :unauthorized
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
