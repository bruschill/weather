Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://localhost:3000"

    resource "/weather", headers: :any, methods: [:get]
  end
end
