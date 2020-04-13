class CreateTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :tokens do |t|
      t.string :hashcode
      t.json :value

      t.timestamps
    end
  end
end
