class GraniteMigration < Huus::Migration

  if Granite::Configuration.all_settings['later_implementation'] == 'mongo_mapper'
    collection 'granite.later.mongo_mapper_later_messages' do
      index [['identifier', asc]], :unique => true
      index [['scheduled_time', asc]]
    end
  end

end