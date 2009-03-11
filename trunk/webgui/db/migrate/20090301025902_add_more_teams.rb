class AddMoreTeams < ActiveRecord::Migration
  def self.up
    f = File.join(RAILS_ROOT, 'db', 'migrate', 'teams.txt')
    File.open(f) do |tf|
      while line = tf.gets
        line.chomp!
        name, short_name = line.split(', ')
        Team.create(:name => name, :short_name => short_name)
      end
    end
  end

  def self.down
    # Not reversible
  end
end
