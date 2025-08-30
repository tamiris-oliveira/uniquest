Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    if Rails.env.development?
      # Em desenvolvimento, permite localhost
      origins [
        "http://localhost:3000",
        "http://localhost:3001", 
        "http://127.0.0.1:3000",
        "http://127.0.0.1:3001"
      ]
    else
      # Em produção, permite apenas domínios específicos do Vercel
      origins [
        "https://uniquest-two.vercel.app",
        "https://uniquest-c8sk8xn99-tamiris73s-projects.vercel.app",
        "https://uniquest-tamiris73s-projects.vercel.app"
      ]
    end

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "Authorization" ],
      credentials: true
  end
end
