require 'thin'
require 'em-websocket'
require 'sinatra/base'
require 'json'
require './helpers/clue_functions'

init_globals

EM.run do
  class App < Sinatra::Base
    get '/' do
      erb :index
    end
    
    get '/remove_user' do
      user = params[:user]
      remove_user(user)
    end
    
    get '/reset' do
      init_globals
      p "Game reset."
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
          gChar = message['character']
          gWeap = message['weapon']
          gRoom = message['room']
          
          msg = {}
          msg['suggestion_made'] = {"character"=>gChar, "weapon"=>gWeap, "room"=>gRoom}
          msg['user'] = message['user']
          
          send_message(msg.to_json)
          
        when "disprove"
          gChar = message['character']
          gWeap = message['weapon']
          gRoom = message['room']
          item = message['disproveItem']
          
          disproved = false
          if item == gChar || item == gWeap || item == gRoom
            disproved = true
          end
          
          msg = {}
          msg["is_disproved"] = disproved
          msg["disprover"] = message['disproover'] # who disproved
          msg["disprovee"] = message['disprovee'] # who is being disproved?
          send_message(msg.to_json)
        
        when "accusation"
          
          gChar = message['character']
          gWeap = message['weapon']
          gRoom = message['room']
          user = message['user']
          
          didWin = false
          if $guilty['character'] == gChar && $guilty['weapon'] == gWeap && $guilty['room'] == gRoom
            didWin = true
          end
          
          msg = {}
          msg['accusation_result'] = didWin
          msg['answer'] = $guilty
          msg['user'] = user
          
          send_message(msg.to_json)
        
        when "notify"
          note = message['note']
          playerList = message['playerList']
          notify_players(playerList, note)
        
        when "get_users"
          msg = {}
          msg["user_update"] = $users
          send_message(msg.to_json)
        else
          p "Uhh..."
        end
      end
    end
  end

  App.run! :port => 3000
end
