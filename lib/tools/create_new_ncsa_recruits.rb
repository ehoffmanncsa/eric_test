# encoding: utf-8
require_relative '../../test/test_helper'

student_count = ARGV[0].nil? ? 1 : ARGV[0]
sport_id = ARGV[1]
enroll_yr = ARGV[2]
need_google_voice = ARGV[3]

for i in 1 .. student_count.to_i
  RecruitAPI.new(enroll_yr, sport_id, need_google_voice).ppost
end
