app = Rpush::Gcm::App.find_or_initialize_by name: 'fcm_app'
app.auth_key = ENV.fetch("FCM_AUTH_KEY")
app.connections = 1
app.save!

puts 'FCM ENABLED'