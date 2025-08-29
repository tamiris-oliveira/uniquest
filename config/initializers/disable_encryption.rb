# Disable ActiveRecord encryption in development
if Rails.env.development?
  Rails.application.configure do
    # Disable ActiveRecord encryption
    config.active_record.encryption.encrypt_fixtures = false
    config.active_record.encryption.store_key_references = false
  end
end
