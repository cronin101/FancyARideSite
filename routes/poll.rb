require 'json'

class FancyARide < Sinatra::Application
  get '/poll' do
    haml :poll
  end

  post '/poll' do
    File.open('./public/poll_results.json', 'a') { |file| file.puts JSON.generate(params) }
    puts "Thanks!"
  end
end
