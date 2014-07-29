require 'thin'
require 'em-websocket'
require 'sinatra/base'
require 'json'
require './helpers/clue_functions'

EM.run do
  class App < Sinatra::Base
    get '/' do
      erb :index
    end
  end

  @clients = []

  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    ws.onopen do |handshake|
      @clients << ws
    end

    ws.onclose do
      @clients.delete ws
    end

    ws.onmessage do |msg|
      
      @clients.each do |socket|
        socket.send msg
      end
      
      # parse the message. Message will say stuff like "player moved", "deal cards", "suggestion made"
      message = JSON.parse(msg)
      if message.include?('event')
        case message['event']
        when "initPlayers"
          $users = {}
          message['players'].each{ |player|
            $users[player] = {}
          }
        when "deal"
          #deal cards and create guilty triple
          dealCards(createDeck)
        when "suggestion"
          p "suggest"
        when "accusation"
          p "accuse"
        when "move"
          p "move"
        else
          p "Uhh..."
        end
      end
    end
  end

  App.run! :port => 3000
end
