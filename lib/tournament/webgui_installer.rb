require 'open3'
require 'fileutils'
require 'net/http'
require 'uri'

class Tournament::WebguiInstaller
  attr_accessor :tmp_dir
  attr_reader :install_dir
  attr_reader :source_dir
  PRINCE_TARBALL='http://www.princexml.com/download/prince-6.0r8-linux.tar.gz'
  RAILS_ENV = ENV['RAILS_ENV'] || 'production'

  def initialize(install_dir)
    @install_dir = install_dir
    @source_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'webgui'))
  end

  def self.download(url, local_file, binary = false)
    url = URI.parse(url)
    open_flag = binary ? "wb" : "w"
    Net::HTTP.start(url.host) do |http|
      File.open(local_file, open_flag) do |file|
        resp = http.get(url.path)
        file.write(resp.body)
      end
    end
  end

  def install_webgui
    FileUtils.cp_r(@source_dir, @install_dir)
  end

  def adjust_configuration(config_options = {})
    config_file = File.expand_path(File.join(@source_dir, 'config', 'initializers', 'pool.rb'))
    target_config = File.expand_path(File.join(@install_dir, 'config', 'initializers', 'pool.rb'))
    puts "  -> Adjusting #{config_file} -> #{target_config}"
    config_contents = File.read(config_file)
    if config_options['email-server']
      smtp_config = {}
      smtp_config[:address] = config_options['email-server']
      smtp_config[:port] = config_options['email-port']
      smtp_config[:domain] = config_options['email-domain'] if config_options['email-domain']
      smtp_config[:user_name] = config_options['email-user'] if config_options['email-user']
      smtp_config[:password] = config_options['email-password'] if config_options['email-password']
      smtp_config[:authentication] = config_options['email-auth'].to_sym if config_options['email-auth']
      config_options['smtp-configuration'] = smtp_config
    end
    [
      ['site-name', 'TOURNAMENT_TITLE'],
      ['admin-email', 'ADMIN_EMAIL'],
      ['relative-root', 'RELATIVE_URL_ROOT'],
      ['smtp-configuration', 'SMTP_CONFIGURATION'],
      ['prince-path', 'PRINCE_PATH']
    ].each do |config_name, constant_name|
      if config_options[config_name]
        puts "  -> Setting config option #{config_name} to #{config_options[config_name]}"
        re = /#{constant_name} =([^\n]+)/m
        config_contents.gsub!(re) do |m|
          "#{constant_name} = #{config_options[config_name].inspect}\n"
        end
      else
        puts "  -> Not setting config option #{config_name}"
      end
    end

    puts "  -> Writing #{target_config}"
    File.open(target_config, "w") do |f|
      f.write config_contents
    end
  end

  def install_prince(prince_install_dir)
    # install prince-xml if necessary
    has_prince = ''
    Open3.popen3('which prince') do |stdin, stdout, stderr|
      has_prince << stdout.read
      has_prince << stderr.read
    end
    if has_prince.empty? || has_prince =~ /no prince/
      puts "Installing prince-xml ..."
      Tournament::WebguiInstaller.download(PRINCE_TARBALL, "#{@tmp_dir}/prince.tgz", true)
      system "tar xzf #{@tmp_dir}/prince.tgz -C #{@tmp_dir}"

      use_sudo = nil
      if !File.exist?(prince_install_dir)
        begin
          FileUtils.makedirs(prince_install_dir)
        rescue
          puts "Could not create install dir for prince, using sudo"
          use_sudo = "sudo "
        end
      elsif !File.writable?(prince_install_dir)
        puts "Prince install directory is not writable, using sudo. You may be asked for your password."
        use_sudo = "sudo "
      end
      puts "cd #{@tmp_dir}/prince-6.0r8-linux && #{use_sudo}bash install.sh"
      system "cd #{@tmp_dir}/prince-6.0r8-linux && #{use_sudo}bash install.sh"
    else
      puts "prince-xml already installed: #{has_prince}"
    end
  end
end

# Run migrations
# Provide instructions for modrails/phusion integration
# Create admin user
# Edit config/initializer/pool.rb to fit
