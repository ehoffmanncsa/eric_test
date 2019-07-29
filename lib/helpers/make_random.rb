module MakeRandom
	def self.number(digits)
    num = digits.times.map{rand(10)}.join
    num = number(digits) if num[0] == '0'
    num
  end

  def self.name(length = nil)
		length ||= 10
    charset = Array('a'..'z')
    Array.new(length) { charset.sample }.join
  end

  def self.grad_yr
  	year = Time.now.year
    (year .. (year + 5)).to_a.sample
  end

  def self.email
    "ncsa.automation+#{SecureRandom.hex(2)}@gmail.com"
  end

	def self.url
		FFaker::InternetSE.http_url
	end

	def self.fake_email
		FFaker::Internet.email
	end

	def self.first_name
		FFaker::Name.first_name
	end

	def self.last_name
		FFaker::Name.last_name
	end

	def self.phone_number
		FFaker.numerify("(###) ###-####")
	end

	def self.zip_code
		num = FFaker::AddressUS.zip_code
		num = zip_code if num[0] == '0'
		num
	end

	def self.company_name
		FFaker::Company.name
	end

	def self.address
		FFaker::AddressUS.street_address
	end

	def self.address2
		FFaker::AddressUS.secondary_address
	end

	def self.city
		FFaker::AddressUS.city
	end

	def self.state
		FFaker::AddressUS.state_abbr
	end

	def self.age_range
		start_rand = rand(12 .. 18)
		end_rand = rand(start_rand .. 18)

		"#{start_rand}-#{end_rand}"
	end

	def self.lorem(sentence_count = 1)
		FFaker::Lorem.paragraph(sentence_count)
	end

	def self.major
		FFaker::Education.major
	end
end
