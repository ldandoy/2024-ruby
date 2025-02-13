class AddUserToWeightEntries < ActiveRecord::Migration[7.2]
  def change
    add_reference :weight_entries, :user, null: false, foreign_key: true
  end
end
