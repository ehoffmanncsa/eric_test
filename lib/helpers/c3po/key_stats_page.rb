module C3PO
  class KeyStatsPage

    def self.fourty_yard_dash
      attributes["40_Yard_Dash"]
    end

    def five_ten_five
      attributes["5-10-5"]
    end

    def three_cone
      attributes["3_Cone"]
    end

    attr_reader :fourty_yard_dash
    attr_reader :fourty_yard_dash_verified
    attr_reader :fourty_yard_dash_date
    attr_reader :five_ten_five_Shuttle
    attr_reader :five_ten_five_Shuttle_verified
    attr_reader :five_ten_five_Shuttle_date
    attr_reader :Bench_Press
    attr_reader :Bench_Press_verified
    attr_reader :Bench_Press_date
    attr_reader :Squat
    attr_reader :Squat_verified
    attr_reader :Squat_date
    attr_reader :Vertical
    attr_reader :Vertical_verified
    attr_reader :Vertical_date
    attr_reader :three_cone
    attr_reader :three_cone_verified
    attr_reader :three_cone_date
    attr_reader :Broad_Jump
    attr_reader :Broad_Jump_verified
    attr_reader :Broad_Jump_date

    def initialize(browser)
      @browser = browser
      make_data
    end

    def key_stats_textfields
      {
        '40_Yard_Dash': @fourty_yard_dash,
        '40_Yard_Dash_verified': @fourty_yard_dash_verified,
        '40_Yard_Dash_date': @fourty_yard_dash_date,
        '5-10-5_Shuttle': @five_ten_five_Shuttle,
        '5-10-5_Shuttle_verified': @five_ten_five_Shuttle_verified,
        '5-10-5_Shuttle_date': @five_ten_five_Shuttle_date,
        Bench_Press: @Bench_Press,
        Bench_Press_verified: @Bench_Press_verified,
        Bench_Press_date: @Bench_Press_date,
        Squat: @Squat,
        Squat_verified: @Squat_verified,
        Squat_date: @Squat_date,
        Vertical: @Vertical,
        Vertical_verified: @Vertical_verified,
        Vertical_date: @Vertical_date,
        '3_Cone_Drill': @three_cone,
        '3_Cone_Drill_verified': @three_cone_verified,
        '3_Cone_Drill_date': @three_cone_date,
        Broad_Jump: @Broad_Jump,
        Broad_Jump_verified: @Broad_Jump_verified,
        Broad_Jump_date: @Broad_Jump_date
      }
    end

    private

    def make_data
      @fourty_yard_dash = MakeRandom.fourty_yard_dash
      @fourty_yard_dash_verified = "Coach" + "#{MakeRandom.last_name}"
      @fourty_yard_dash_date = MakeRandom.key_stats_date
      @five_ten_five_Shuttle = MakeRandom.fourty_yard_dash
      @five_ten_five_Shuttle_verified ="Coach" + "#{MakeRandom.last_name}"
      @five_ten_five_Shuttle_date = MakeRandom.key_stats_date
      @Bench_Press = MakeRandom.bench_squat
      @Bench_Press_verified = "Coach" + "#{MakeRandom.last_name}"
      @Bench_Press_date = MakeRandom.key_stats_date
      @Squat = MakeRandom.bench_squat
      @Squat_date = MakeRandom.key_stats_date
      @Squat_verified = "Coach" + "#{MakeRandom.last_name}"
      @Vertical = MakeRandom.vertical
      @Vertical_date = MakeRandom.key_stats_date
      @Vertical_verified = "Coach" + "#{MakeRandom.last_name}"
      @three_cone = MakeRandom.three_cone
      @three_cone_verified = "Coach" + "#{MakeRandom.last_name}"
      @three_cone_date = MakeRandom.key_stats_date
      @Broad_Jump = MakeRandom.broad_jump
      @Broad_Jump_verified = "Coach" + "#{MakeRandom.last_name}"
      @Broad_Jump_date = MakeRandom.key_stats_date
    end
  end
end
