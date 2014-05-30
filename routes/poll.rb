class FancyARide < Sinatra::Application
  get '/poll.html' do
    haml :poll
  end
end
