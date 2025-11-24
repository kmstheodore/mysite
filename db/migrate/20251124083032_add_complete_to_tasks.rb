class AddCompleteToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :complete, :boolean, default: false, null: false
  end
end
