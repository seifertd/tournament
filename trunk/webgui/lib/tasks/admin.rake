namespace :admin do
  desc 'Create admin user.'
  task :create, [:login, :email, :name, :password] => [:environment] do |t, args|
    user_attributes = [:login, :email, :name, :password].inject({}) do |hash, var|
      raise "Got blank task parameter #{var.inspect}" unless args.send(var)
      hash.merge!(var => args.send(var))
    end
    User.create_admin_user(user_attributes)
  end
end
