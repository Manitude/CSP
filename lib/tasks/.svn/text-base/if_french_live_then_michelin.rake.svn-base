namespace :if_french_live_then_michelin do
  desc "TO add michelin to all coaches who handle french live"
  task :addMichelin => :environment do
  	frenchlive = Language["TMM-FRA-L"].id
  	frenchLiveCoaches = Qualification.find_all_by_language_id(frenchlive).collect(&:coach).compact
  	frenchLiveManagers = Qualification.find_all_by_language_id(frenchlive).collect(&:manager).compact
  	michelin = Language.find_by_identifier("TMM-MCH-L")
  	#update in supersaas for coaches alone
  	frenchLiveCoaches.each do |coach|
        coach.update_or_create_qualification(michelin.id, 1)
        coach.update_saas
        puts "Updating coach : #{coach.id}"
  	end
  	#do not add the michelin qualification if already exists
  	frenchLiveManagers.each do |cm|
        cm.add_qualifications_for(michelin.id) unless cm.qualifications.detect{|q|q.language_id == michelin.id}
        puts "Updating manager : #{cm.id}"
  	end
    puts "Task completed"
  end
end