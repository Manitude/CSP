namespace :create_RSA_coaches_on_saas do
	desc "To add Phone coaches on supersaas"
	task :addPhoneCoachesToSupersaas => :environment do
		phone = TMMPhoneLanguage.all
		coach_list=[]
		phone.each do |lang|
			coach_list << lang.coaches
		end
		coaches = coach_list.flatten.compact.uniq
		coaches.each do |coach|
			coach.update_attribute(:coach_guid, RosettaStone::UUIDHelper.generate) if coach.coach_guid.blank?
			SuperSaas::Coach.create_or_update(coach,"supersaas2")
			 puts "Creating RSAPhone coach : #{coach.id} on supersaas"
		end
		puts "Task Completed"
	end

	desc "To add Michelin Coaches on RSAsupersaas"
	task :addMichelinCoachesToRSASupersaas => :environment do
		michelin = Language.find_by_identifier("TMM-MCH-L")
		coach_list = michelin.coaches.compact.uniq
		coach_list.each do |coach|
			coach.update_attribute(:coach_guid, RosettaStone::UUIDHelper.generate) if coach.coach_guid.blank?
			SuperSaas::Coach.create_or_update(coach,"supersaas2")
			puts "Creating RSAMichelin coach : #{coach.id} on RSAsupersaas"
		end
		puts "Task Completed"
	end
end


			

