# encoding: utf-8
require_relative '../../test/test_helper'
require_relative 'make_random'
# This class is to create CSV for multiple athletes
class AtheteCSV
  def initialize
  	@headers = ['First Name', 'Last Name', 'Email', 'Primary Team',
  				'Graduation Year', 'Zip Code', 'Phone']
  	@team = '18 Elite'
  end

  def generate_data
  	@firstname = MakeRandom.name
  	@lastname = MakeRandom.name
  	@email = MakeRandom.email
  	@grad_yr = MakeRandom.grad_yr
  	@zipcode = MakeRandom.number(5)
  	@phone = MakeRandom.number(10)
  end

  def make_it
  	CSV.open('athletes.csv', 'w', write_headers: true, headers: @headers) do |csv|
      rand(2 .. 4).times do |i|
      	generate_data
        csv << [@firstname, @lastname, @email, @team, @grad_yr, @zipcode, @phone]
      end
    end
  end
end
