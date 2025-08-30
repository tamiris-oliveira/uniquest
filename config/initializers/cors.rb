Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Em desenvolvimento, permite qualquer origem
    if Rails.env.development?
      origins "*"
    else
      # Em produção, permite o frontend Vercel e outros domínios necessários
      origins [
        "https://uniquest-two.vercel.app",
        "https://uniquest-c8sk8xn99-tamiris73s-projects.vercel.app",
        "https://uniquest-tamiris73s-projects.vercel.app",
        /https:\/\/uniquest-.*\.vercel\.app/,  # Permite qualquer deploy do Vercel
        ENV["FRONTEND_URL"]
      ].compact
    end

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "Authorization" ],
      credentials: true
  end
end
