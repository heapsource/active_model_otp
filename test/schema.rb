ActiveRecord::Schema.define do
  self.verbose = false

  create_table :activerecord_users, force: true do |t|
    t.string :key
    t.string :email
    t.integer :otp_counter
    t.string :otp_secret_key
    t.timestamps
  end

  create_table :interval_users, force: true do |t|
    t.string :key
    t.string :email
    t.integer :otp_counter
    t.string :otp_secret_key
    t.timestamps
  end

  create_table :default_interval_users, force: true do |t|
    t.string :key
    t.string :email
    t.integer :otp_counter
    t.string :otp_secret_key
    t.timestamps
  end
end
