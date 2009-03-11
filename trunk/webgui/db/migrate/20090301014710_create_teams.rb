class CreateTeams < ActiveRecord::Migration
  class Team < ActiveRecord::Base; end
  def self.up
    create_table :teams do |t|
      t.string :name
      t.string :short_name

      t.timestamps
    end

      [   
        ['North Carolina', 'UNC', 1],
        ['Mt. St. Mary\'s', 'MSM', 16],
        ['Indiana', 'Ind', 8],
        ['Arkansas', 'Ark', 9],
        ['Notre Dame', 'ND', 5],
        ['George Mason', 'GM', 12],
        ['Washington St.', 'WSt', 4],
        ['Winthrop', 'Win', 13],
        ['Oklahoma', 'Okl', 6],
        ['St. Joseph\'s', 'StJ', 11],
        ['Louisville', 'Lou', 3],
        ['Boise St.', 'BSt', 14],
        ['Butler', 'But', 7],
        ['South Alabama', 'SAl', 10],
        ['Tennessee', 'Ten', 2],
        ['American', 'Am', 15],
        ['Kansas', 'Kan', 1],
        ['Portland St.', 'PSt', 16],
        ['UNLV', 'ULV', 8],
        ['Kent St.', 'KSt', 9],
        ['Clemson', 'Clm', 5],
        ['Villanova', 'Vil', 12],
        ['Vanderbilt', 'Van', 4],
        ['Siena', 'Sie', 13],
        ['USC', 'USC', 6],
        ['Kansas St.', 'KSU', 11],
        ['Wisconsin', 'Wis', 3],
        ['CSU Fullerton', 'CSF', 14],
        ['Gonzaga', 'Gon', 7],
        ['Davidson', 'Dav', 10],
        ['Georgetown', 'GT', 2],
        ['UMBC', 'UBC', 15],
        ['Memphis', 'Mem', 1],
        ['TX Arlington', 'TxA', 16],
        ['Mississippi St.', 'MiS', 8],
        ['Oregon', 'Ore', 9],
        ['Michigan St.', 'MSU', 5],
        ['Temple', 'Tem', 12],
        ['Pittsburgh', 'Pit', 4],
        ['Oral Roberts', 'ORo', 13],
        ['Marquette', 'Mar', 6],
        ['Kentucky', 'Ken', 11],
        ['Stanford', 'Sta', 3],
        ['Cornell', 'Cor', 14],
        ['Miami (FL)', 'Mia', 7],
        ['St. Mary\'s', 'StM', 10],
        ['Texas', 'Tex', 2],
        ['Austin Peay', 'APe', 15],
        ['UCLA', 'ULA', 1],
        ['Mis. Valley St', 'MVS', 16],
        ['BYU', 'BYU', 8],
        ['Texas A&M', 'A&M', 9],
        ['Drake', 'Dra', 5],
        ['W. Kentucky', 'WKy', 12],
        ['Connecticut', 'Con', 4],
        ['San Diego', 'SD', 13],
        ['Purdue', 'Pur', 6],
        ['Baylor', 'Bay', 11],
        ['Xavier', 'Xav', 3],
        ['Georgia', 'UG', 14],
        ['West Virginia', 'WVa', 7],
        ['Arizona', 'UA', 10],
        ['Duke', 'Duk', 2],
        ['Belmont', 'Bel', 15]
      ].each do |name, short_name, x|
        Team.create(:name => name, :short_name => short_name)
      end
  end

  def self.down
    drop_table :teams
  end
end
