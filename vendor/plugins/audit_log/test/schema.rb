ActiveRecord::Schema.define(:version => 1) do

  create_table :albums, :force => true do |t|
    t.column :artist_id,    :integer
    t.column :title,        :string
    t.column :producers,    :string
    t.column :label,        :string
    t.column :rating,       :integer
  end

  create_table :artists, :force => true do |t|
    t.column :name,         :string
    t.column :type,         :string
    t.column :year_formed,  :integer
    t.column :home_town,    :string
    t.column :created_at,   :datetime
  end

  create_table :songs, :force => true do |t|
    t.column :name,         :string
  end

end