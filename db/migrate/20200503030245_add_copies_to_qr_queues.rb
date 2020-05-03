class AddCopiesToQrQueues < ActiveRecord::Migration[6.0]
  def change
    add_column :qr_queues, :copies, :integer
  end
end
