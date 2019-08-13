module C3PO
  class AcademicsPage
    attr_reader :high_school_conference
    attr_reader :overall_gpa
    attr_reader :transcript
    attr_reader :core_gpa
    attr_reader :weighted_gpa
    attr_reader :class_rank
    attr_reader :class_size
    attr_reader :weighted_class_rank
    attr_reader :weighted_class_rank_size
    attr_reader :sat_math
    attr_reader :sat_reading_writing
    attr_reader :psat_score
    attr_reader :sat_notes
    attr_reader :act_score
    attr_reader :plan_score
    attr_reader :act_notes
    attr_reader :honors_courses
    attr_reader :ap_courses
    attr_reader :academic_awards
    attr_reader :extracurricular_notes

    def initialize(browser)
      @browser = browser
      make_data
    end

    def academics_textfields
      {
        high_school_conference: @high_school_conference,
        overall_gpa: @overall_gpa,
        core_gpa: @core_gpa,
        weighted_gpa: @weighted_gpa,
        class_rank: @class_rank,
        class_size: @class_size,
        weighted_class_rank: @weighted_class_rank,
        weighted_class_rank_size: @weighted_class_rank_size,
        sat_math: @sat_math,
        sat_reading_writing: @sat_reading_writing,
        psat_score: @psat_score,
        sat_notes: @sat_notes,
        act_score: @act_score,
        plan_score: @plan_score,
        act_notes: @act_notes
      }
    end

    def academics_textareas
      {
        honors_courses: @honors_courses,
        ap_courses: @ap_courses,
        academic_awards: @academic_awards,
        extracurricular_notes: @extracurricular_notes
      }
    end

    private

    def make_data
      @high_school_conference = MakeRandom.conference
      @overall_gpa = MakeRandom.gpa
      @transcript = MakeRandom.lorem_words
      @core_gpa = MakeRandom.gpa
      @weighted_gpa = MakeRandom.gpa
      @class_rank = MakeRandom.number(2)
      @class_size = MakeRandom.number(3)
      @weighted_class_rank = MakeRandom.number(2)
      @weighted_class_rank_size = MakeRandom.number(3)
      @sat_reading_writing = MakeRandom.sat
      @sat_math = MakeRandom.sat
      @psat_score = MakeRandom.psat
      @sat_notes = MakeRandom.lorem_words
      @act_score = MakeRandom.act
      @plan_score = MakeRandom.act
      @act_notes = MakeRandom.lorem_words
      @honors_courses = MakeRandom.lorem
      @ap_courses = MakeRandom.lorem
      @academic_awards = MakeRandom.lorem
      @extracurricular_notes = MakeRandom.lorem
    end
  end
end
