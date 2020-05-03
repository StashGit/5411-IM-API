class CreateQrQueues < ActiveRecord::Migration[6.0]
  def change
    create_table :qr_queues do |t|
      t.integer :qr_id
      t.boolean :printed, default: false

      t.timestamps
    end
  end
end
