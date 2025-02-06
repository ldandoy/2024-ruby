class CreateWeightEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :weight_entries do |t|
      t.decimal :weight
      t.date :date

      t.timestamps
    end
  end
end
