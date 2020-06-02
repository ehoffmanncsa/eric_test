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

	def self.alpha(length = nil)
		length ||= 1
    charset = Array('a'..'z')
    Array.new(length) { charset.sample }.join
  end

  def self.grad_yr
  	year = Time.now.year
    (year .. (year + 4)).to_a.sample
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

	def self.high_school
		FFaker::Education.school
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
		start_rand = rand(13 .. 19)
		end_rand = rand(start_rand .. 19)

		"#{start_rand}-#{end_rand}"
	end

	def self.gpa
    loop do
      gpa = rand(1.0 .. 6.0).round(2).to_s
      return gpa if gpa.chars.last != '0'
    end
  end

	def self.act
		rand(15 .. 32)
	end

	def self.sat
		rand = rand(200 .. 800)
	end

	def self.psat
		rand = rand(320 .. 1520)
	end

	def self.lorem(sentence_count = 1)
		FFaker::Lorem.paragraph(sentence_count)
	end

	def self.lorem_words(word_count = 8)
		FFaker::Lorem.sentence(word_count)
	end

	def self.major
		FFaker::Education.major
	end

	def self.conference
		FFaker::Conference.name
	end

	def self.fourty_yard_dash
		rand(4.9 .. 9.5).round(2)
	end

	def self.three_cone
		rand(4.9 .. 9.5).round(2)
	end

	def self.bench_squat
		rand(225 .. 500)
	end

	def self.vertical
		rand(28.1 .. 40.5).round(2)
	end

	def self.broad_jump
		rand(100 .. 150).round(2)
	end

	def self.key_stats_date
    target_day = Date.today
    date = target_day.strftime("%m/%d/%Y")
  end

end
