namespace :admin do
  desc 'Create admin user.'
  task :create => [:environment] do
    user_attributes = [:login, :email, :name, :password].inject({}) do |hash, var|
      env_key = var.to_s.upcase
      raise "Set admin user #{var} using #{env_key}=value" if ! ENV[env_key]
      hash.merge!(var => ENV[env_key])
    end
    user_attributes.merge!(:password_confirmation => user_attributes[:password])
    puts "Creating admin user: #{user_attributes.inspect}"
    u = User.new(user_attributes)
    u.activated_at = Time.now
    u.roles << Role[:admin]
    u.save!
  end
end
