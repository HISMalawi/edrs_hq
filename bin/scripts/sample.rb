def sample_random(population)
	random_number = rand(population.count - 1)
	random_id = population[random_number]
	return random_id
end



