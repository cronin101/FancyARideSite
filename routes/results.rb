require 'json'

class FancyARide < Sinatra::Application
  get '/results' do
    parse_results
    rankings_by_male_or_female = calculate_rankings_by_male_or_female
    gender_counts = count_gender
    @male_rankings = rankings_by_male_or_female['m'].values
    @male_rankings.map! {|x| x / gender_counts['m'].to_f}
    @female_rankings = rankings_by_male_or_female['f'].values
    @female_rankings.map! {|y| y / gender_counts['f'].to_f}
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

  def calculate_rankings_by_male_or_female
    rank_entries = ['ranking_route_map', 'ranking_parking', 'ranking_bike_shops', 'ranking_air', 'ranking_accidents']
    results = {'m' => {'ranking_route_map' => 0.0, 'ranking_parking' => 0.0, 'ranking_bike_shops' => 0.0, 'ranking_air' => 0.0, 'ranking_accidents' => 0.0}, 'f' => {'ranking_route_map' => 0.0, 'ranking_parking' => 0.0, 'ranking_bike_shops' => 0.0, 'ranking_air' => 0.0, 'ranking_accidents' => 0.0}}
    @raw_results.each do |idx, poll_entry|
      gender = poll_entry['gender']
      rank_entries.each do |rank|
        begin
          score = poll_entry[rank].to_f
          if score != 0.0
            results[gender][rank] += (1/score)
          end
        rescue
          puts "missing data"
        end
      end
    end
    results
  end
end





