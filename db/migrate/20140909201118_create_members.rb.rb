class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |table|
      table.string :role, null: false
      table.integer :user_id, null: false
      table.integer :meetup_id, null:false
      table.timestamps
    end
  end
end
