require 'thin'
require 'em-websocket'
require 'sinatra/base'
require 'json'
require './helpers/clue_functions'

$users = {}

EM.run do
  class App < Sinatra::Base
    get '/' do
      erb :index
    end
    
  end

  $clients = []

  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    ws.onopen do |handshake|
      $clients << ws
    end

    ws.onclose do
      $clients.delete ws
    end

    ws.onmessage do |msg|
      
      $clients.each do |socket|
        socket.send msg
      end
      
      # parse the message. Message will say stuff like "player moved", "deal cards", "suggestion made"
      message = JSON.parse(msg)
      p message
      if message.include?('event')
        case message['event']
        when "add_user"
          add_user(message['username'])
        when "remove_user"
          remove_user(message['username'])
        when "deal"
          #deal cards and create guilty triple
          dealCards(createDeck)
        when "move"
        
        when "turnSwitch"
          
        when "suggestion"
          p "suggest"
          
        when "disprove"
          p "disprove"
        when "accusation"
          p "accuse"
        else
          p "Uhh..."
        end
      end
    end
  end

  App.run! :port => 3000
end
