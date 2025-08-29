Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Em desenvolvimento, permite qualquer origem
    if Rails.env.development?
      origins "*"
    else
      # Em produção, especifique os domínios do seu frontend
      origins ENV.fetch("FRONTEND_URL", "https://your-frontend-domain.com")
    end

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "Authorization" ]
  end
end
