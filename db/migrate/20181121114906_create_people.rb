class CreatePeople < ActiveRecord::Migration[5.2]
  def change
    create_table :people do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :maiden_name, null: true
      t.string :gender, null: false
      t.integer :depth, null: false

      t.references :spouse, class_name: 'Person'
      t.references :mother, class_name: 'Person'
      t.references :father, class_name: 'Person'

      t.timestamps
    end
  end
end
