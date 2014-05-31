class FancyARide < Sinatra::Application
  get '/results' do
    haml :results
  end
end
