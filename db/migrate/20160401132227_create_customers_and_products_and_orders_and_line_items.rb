class CreateCustomersAndProductsAndOrdersAndLineItems < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name
      t.timestamps null: false
    end

    create_table :products do |t|
      t.string :name
      t.text :description
      t.string :category
      t.decimal :unit_price
      t.boolean :discontinued, default: false, null: false
      t.timestamps null: false
    end

    create_table :orders do |t|
      t.references :customer
      t.string :status
      t.timestamps null: false
    end

    create_table :line_items do |t|
      t.references :order
      t.references :product
      t.integer :quantity
      t.decimal :price
      t.timestamps null: false
    end
  end
end
