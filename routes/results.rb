require 'json'

class FancyARide < Sinatra::Application
  get '/results' do
    parse_results
    rankings_by_male_or_female = calculate_rankings_by_male_or_female
    gender_counts = count_gender
    @number_of_cyclists = count_cyclists
    @number_of_people = @raw_results.size
    @cycle_percent = (100*@number_of_cyclists/@number_of_people.to_f).round(2)
    @male_rankings = rankings_by_male_or_female['m'].values
    @male_rankings.map! {|x| x / gender_counts['m'].to_f}
    @female_rankings = rankings_by_male_or_female['f'].values
    @female_rankings.map! {|y| y / gender_counts['f'].to_f}
    @cycle_hist = cycle_app_hist.values
    @max_freq = @cycle_hist.max

    reasons_by_app_use = reason_for_cycling_by_use_of_app
    @yes_reasons = reasons_by_app_use["yes"].values
    @yes_reasons[1] += 1
    @no_reasons = reasons_by_app_use["no"].values
    haml :results
  end

  def parse_results
    @raw_results = {}
    File.readlines('./public/poll_results.json').each_with_index do |line, idx|
        @raw_results[idx] = JSON.parse(line)
    end
  end

  def count_gender
    counts = {'m' => 0, 'f' => 0}
    @raw_results.each do |idx, poll_entry|
      begin
        counts[poll_entry['gender']] += 1
      rescue
        puts "missing data"
      end
    end
    counts
  end

  def count_cyclists
    number_of_cyclists = 0
    @raw_results.each do |idx, poll_entry|
      begin
        if poll_entry['cycle_yn'] == "yes"
          number_of_cyclists += 1
        end
      rescue
        puts "missing data"
      end
    end
    number_of_cyclists
  end

  def cycle_app_hist
    histogram = {"daily" => 0, "weekly" => 0, "monthly" => 0, "occasionally" => 0, "never" => 0, "unsure" => 0}
    @raw_results.each do |idx, poll_entry|
      begin
        if poll_entry.fetch("cycle_apps_yn", nil) == "yes"
          app_freq = poll_entry.fetch("cycle_app_freq", nil)
          unless app_freq.nil?
            histogram[app_freq] += 1
          end
        end
      rescue
        puts "missing data"
      end
    end
    histogram
  end

  def calculate_rankings_by_male_or_female
    rank_entries = ['ranking_route_map', 'ranking_parking', 'ranking_bike_shops', 'ranking_air', 'ranking_accidents']
    results = {'m' => {'ranking_route_map' => 0.0, 'ranking_parking' => 0.0, 'ranking_bike_shops' => 0.0, 'ranking_air' => 0.0, 'ranking_accidents' => 0.0}, 'f' => {'ranking_route_map' => 0.0, 'ranking_parking' => 0.0, 'ranking_bike_shops' => 0.0, 'ranking_air' => 0.0, 'ranking_accidents' => 0.0}}
    @raw_results.each do |idx, poll_entry|
      gender = poll_entry['gender']
      rank_entries.each do |rank|
        begin
          score = poll_entry[rank].to_f
          if score != 0.0
            results[gender][rank] += score
          end
        rescue
          puts "missing data"
        end
      end
    end
    results
  end

  def reason_for_cycling_by_use_of_app
    results = {"yes" => {"work" => 0, "school" => 0, "around" => 0, "fun" => 0, "exercise" => 0, "other" => 0}, "no" => {"work" => 0, "school" => 0, "around" => 0, "fun" => 0, "exercise" => 0, "other" => 0}}
    @raw_results.each do |idx, poll_entry|
      uses_apps = poll_entry["cycle_apps_yn"]
      begin
        my_reason = poll_entry.fetch("cycle_yes", nil)
        unless my_reason.nil?
          results[uses_apps][my_reason] += 1
        end
      rescue
        puts "missing data"
      end
    end
    results
  end
end





