def sample_random(population)
	random_number = rand(population.count - 1)
	random_id = population[random_number]
	return random_id
end

User.by_role.key("Coder").each do |user|

	sampling_frequency = SETTINGS['sampling_frequency']
	case sampling_frequency
	when "Daily"
		start_time = Time.now.beginning_of_day
		end_time = Time.now
	when "Weekly"	
		start_time = Time.now.beginning_of_week
		end_time = Time.now
	when "Monthly"
		start_time = Time.now.beginning_of_week
		end_time = Time.now		
	end

	coders_records = Person.by_coder_and_coded_at.startkey([user.id, start_time]).endkey([user.id, end_time]).each.collect {|p| p.id}
	
	percent = ((SETTINGS['sample_percentage'].to_f/100) * coders_records.count).ceil

	puts percent
	
	sample = []

	for i in 0..(percent - 1)
		population = coders_records - sample
		id = sample_random(population)
		sample << id unless id.blank?
	end
	unless sample.blank?
		proficiency_sample = ProficiencySample.new
		proficiency_sample.coder_id = user.id
		proficiency_sample.sample = sample.sort
		proficiency_sample.start_time = start_time
		proficiency_sample.end_time = end_time
		proficiency_sample.date_sampled = Date.today
		proficiency_sample.save
	end

end

