class CreateRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :records do |t|
      t.string :triangle_name
      t.string :pair1
      t.string :pair2
      t.string :pair3
      t.float :profit
      t.string :exchange
      t.datetime :date

      t.timestamps
    end
  end
end
