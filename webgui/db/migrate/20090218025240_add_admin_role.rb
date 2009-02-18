class AddAdminRole < ActiveRecord::Migration
  def self.up
    Role.enumeration_model_updates_permitted = true
    Role.create(:name => 'admin', :position => 1)
  end

  def self.down
    Role[:admin].destroy
  end
end
