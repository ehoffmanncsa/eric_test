module MakeRandom
	def self.number(digits)
    charset = Array('0'..'9')
    Array.new(digits) { charset.sample }.join
  end

  def self.name
    charset = Array('a'..'z')
    Array.new(10) { charset.sample }.join
  end

  def self.grad_yr
  	year = Time.now.year
    ((year - 5) .. (year + 10)).to_a.sample
  end
end
