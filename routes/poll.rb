require 'json'

class FancyARide < Sinatra::Application
  get '/poll' do
    haml :poll
  end

  post '/poll' do
    File.open('poll_results.txt', 'a') { |file| file.write(JSON.generate(params)+"\n") }
    haml :poll
  end
end
