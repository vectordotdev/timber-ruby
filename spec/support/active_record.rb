require 'active_record'

ActiveRecord::Base.logger = Rails.logger
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, :force => true do |t|
    t.string :first_name
    t.integer :age

    t.timestamps :null => false
  end

end
