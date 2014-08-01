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
          setLegalRooms
          dealCards(createDeck)
          
        when "move"
          user = message['user']
          newRoom = message['newRoom']
          canMove = move_player(user, newRoom)
          msg = {}
          msg['user'] = user
          msg['move_reply'] = canMove
          
          send_message(msg.to_json)   
             
        when "turnSwitch"
          players = $users.keys
          tmpTurn = $currentTurn
          
          indexVal = players.index(tmpTurn) + 1
          indexVal = 0 if indexVal >= players.length

          $currentTurn = players[indexVal]
          msg = {}
          msg['newTurn'] = $currentTurn
          send_message(msg.to_json)   
             
        when "suggestion"
          
        when "disprove"
          p "disprove"
        when "accusation"
          
          gChar = message['character']
          gWeap = message['weapon']
          gRoom = message['room']
          
          didWin = false
          if $guilty['character'] == gChar && $guilty['weapon'] == gWeap && $guilty['room'] == gRoom
            didWin = true
          end
          
          msg = {}
          msg['accusation_result'] = didWin
          msg['answer'] = $guilty
          
          send_message(msg.to_json)
        else
          p "Uhh..."
        end
      end
    end
  end

  App.run! :port => 3000
end
