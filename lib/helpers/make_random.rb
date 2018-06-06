module MakeRandom
	def self.number(digits)
    num = nil
    loop do
      num = digits.times.map{rand(10)}.join
      break if num[0] != '0'
    end

    num
  end

  def self.name
    charset = Array('a'..'z')
    Array.new(10) { charset.sample }.join
  end

  def self.grad_yr
  	year = Time.now.year
    ((year - 5) .. (year + 10)).to_a.sample
  end

  def self.email
    "ncsa.automation+#{SecureRandom.hex(2)}@gmail.com"
  end

	def self.first_name
		FFaker::Name.first_name
	end

	def self.last_name
		FFaker::Name.last_name
	end

	def self.phone_number
		FFaker::PhoneNumber.short_phone_number
	end

	def self.zip_code
		num = nil
    loop do
      num = FFaker::AddressUS.zip_code
      break if num[0] != '0'
    end

    num
	end
end
