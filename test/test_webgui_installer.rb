require 'test/unit'
require 'tournament'
require 'fileutils'

class Val
  def initialize(val); @val = val; end
  def given?; true; end
  def value; @val; end
end

class WebguiInstallerTest < Test::Unit::TestCase
  def setup
    @tmp_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'tmp'))
    FileUtils.mkdir_p @tmp_dir
    @installer = Tournament::WebguiInstaller.new(File.join(@tmp_dir, "test_install"))
    @installer.tmp_dir = @tmp_dir
  end

  def teardown
    FileUtils.rm_r @tmp_dir
  end

  def test_instantiate
    assert_equal File.join(@tmp_dir, "test_install"), @installer.install_dir
    assert_equal File.expand_path(File.join(File.dirname(__FILE__), '..', 'webgui')), @installer.source_dir
  end

  def test_install_webgui
    @installer.install_webgui
    assert File.exist?(@installer.install_dir)
    @installer.adjust_configuration( 
      Hash.new {|h,k| h[k] = Val.new(k.gsub('-', '_').upcase) }
    )
    assert_match /PRINCE_PATH = "PRINCE_PATH"/, File.read(File.join(@installer.install_dir, 'config', 'initializers', 'pool.rb'))
  end

  def test_install_webgui_minimal
    @installer.install_webgui
    assert File.exist?(@installer.install_dir)
    @installer.adjust_configuration( 
      {
        'prince-path' => Val.new('foo'),
        'admin-email' => Val.new('admin@admin.com'),
        'site-name' => Val.new('My Site')
      }
    )
    new_config = File.read(File.join(@installer.install_dir, 'config', 'initializers', 'pool.rb'))
    assert_match /PRINCE_PATH = "foo"/, new_config
    assert_match /TOURNAMENT_TITLE = "My Site"/, new_config
    assert_match /ADMIN_EMAIL = "admin@admin.com"/, new_config
  end

  #def test_prince_install
  #  @installer.install_prince(File.join(@tmp_dir, 'prince_install'))
  #end

end
