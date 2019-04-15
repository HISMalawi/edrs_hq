require 'spec_helper.rb'
describe 'PersonIdentifier'  do
	context 'Generate drn' do
		it 'with length of 11' do
			person = Person.first
			drn = PersonIdentifier.generate_drn(person)
			expect(drn[0].length).to eq(11)
		end
	end
end