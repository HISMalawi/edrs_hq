def sample_random(population)
	random_number = rand(population.count - 1)
	random_id = population[random_number]
	return random_id
end

User.by_role.key("Coder").each do |user|
	start_time  = ProficiencySample.by_coder_id_and_end_time.last
	start_time = end_time + 1.seconds
	end_time = Time.now
	coders_records = Person.by_coder_and_coded_at.starkey([user.id, start_time]).endkey([user.id, end_time]).each.collect {|p| p.id}
	five_percent = ((5/100) * coders_records.count).to_i
	sample = []
	for i in 0..five_percent
		population = coders_records - sample
		sample << sample_random(population)
	end

	proficiency_sample = ProficiencySample.new
	proficiency_sample.coder_id = userr.id
	proficiency_sample.sample = sample
	proficiency_sample.start_time = start_time
	proficiency_sample.end_time = end_time
	proficiency_sample.save
end

