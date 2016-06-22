class CreateMains < ActiveRecord::Migration
  def change
    create_table :mains do |t|
      t.string :api_key
      t.string :sheet_id
      t.timestamps
    end
  end
end
